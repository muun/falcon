//
//  LNURLWithdrawViewController.swift
//  falcon
//
//  Created by Federico Bond on 09/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

class LNURLWithdrawViewController: MUViewController {

    enum State {
        case contacting(domain: String)
        case receiving(domain: String)
        case invoiceCreated
        case tooLong(domain: String)
        case success
        case failed(error: ErrorViewModel)

        func loggingName() -> String {
            switch self {
            case .contacting:
                return "contacting"
            case .invoiceCreated:
                return "invoice_created"
            case .receiving:
                return "receiving"
            case .tooLong:
                return "taking_too_long"
            case .success:
                return "success"
            case .failed:
                return "failed"
            }
        }
    }

    private let loading = LNURLLoadingView()

    override var screenLoggingName: String {
        return "lnurl_withdraw"
    }

    private let qr: String
    private let errorView = ErrorView()

    private lazy var presenter = instancePresenter(LNURLWithdrawPresenter.init, delegate: self, state: qr)

    init(qr: String) {
        self.qr = qr
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        view = UIView()
        setUpView()
    }

    private func setUpView() {
        loading.titleText = L10n.LNURLWithdrawViewController.loading
        loading.delegate = self
        loading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loading)

        NSLayoutConstraint.activate([
            loading.topAnchor.constraint(equalTo: view.topAnchor),
            loading.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loading.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loading.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.isNavigationBarHidden = false

        presenter.tearDown()
    }

    private func setUpNavigation() {
        title = L10n.LNURLWithdrawViewController.title
    }

    func showError(_ error: ErrorViewModel) {
        errorView.delegate = self
        errorView.model = error

        errorView.addTo(view)
        // view.gestureRecognizers?.removeAll()

        navigationController?.isNavigationBarHidden = true
    }

    func hideError() {
        errorView.removeFromSuperview()

        navigationController?.isNavigationBarHidden = false
    }

    private func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
        guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
            return nil
        }

        let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (_) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        return action
    }

}

extension LNURLWithdrawViewController: ErrorViewDelegate {
    func retryTouched(button: ButtonView) {
        presenter.retry()
        hideError()
    }

    func sendReportTouched() {
        let muunEmail = "support@muun.com"
        let query = presenter.getReportURLQueryParams()

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = openAction(withURL: "mailto:\(muunEmail)?\(query)", andTitleActionTitle: "Mail") {
            actionSheet.addAction(action)
        }

        if let action = openAction(withURL: "googlegmail://co?to=\(muunEmail)&\(query)", andTitleActionTitle: "Gmail") {
            actionSheet.addAction(action)
        }

        if let action = openAction(withURL: "ms-outlook://compose?to=\(muunEmail)&\(query)",
                                   andTitleActionTitle: "Outlook") {
            actionSheet.addAction(action)
        }

        actionSheet.addAction(
            UIAlertAction(
                title: L10n.LNURLWithdrawViewController.copyToClipboard,
                style: .default,
                handler: { _ in
                    let report = self.presenter.getReportForClipboard()
                    UIPasteboard.general.string = report
                })
        )

        navigationController!.present(actionSheet, animated: true)
    }

    func logErrorView(_ name: String, params: [String: Any]?) {
        logScreen(name, parameters: params)
    }

    func secondaryButtonTouched() {
        navigationController!.popToRootViewController(animated: true)
    }

}

extension LNURLWithdrawViewController: LNURLWithdrawPresenterDelegate {

    func updateState(_ state: State) {
        logEvent("lnurl_withdraw_state", parameters: ["type": state.loggingName()])

        switch state {
        case .contacting(let domain):
            let localizedDescription = L10n.LNURLWithdrawViewController.contacting(domain)
            loading.attributedTitleText = NSMutableAttributedString(string: localizedDescription)
                .set(bold: domain, color: Asset.Colors.title.color)
            loading.descriptionText = ""
            loading.isTakingTooLong = false

        case .receiving(let domain):
            let localizedDescription = L10n.LNURLWithdrawViewController.receiving(domain)
            loading.attributedTitleText = NSMutableAttributedString(string: localizedDescription)
                .set(bold: domain, color: Asset.Colors.title.color)
            loading.descriptionText = ""
            loading.isTakingTooLong = false

        case .tooLong(let domain):
            loading.attributedTitleText = L10n.LNURLWithdrawViewController.tooLong(domain)
                .set(font: Constant.Fonts.system(size: .desc), alignment: .center)
                .set(bold: domain, color: Asset.Colors.title.color)
            loading.attributedDescriptionText = L10n.LNURLWithdrawViewController.tooLongDescription(domain)
                .attributedForDescription(alignment: .center)
                .set(bold: domain, color: Asset.Colors.title.color)
            loading.isTakingTooLong = true

        case .failed(let error):
            showError(error)

        case .invoiceCreated:
            break

        case .success:
            navigationController!.popToRootViewController(animated: true)
        }
    }

    func returnToHome() {
        navigationController!.popToRootViewController(animated: true)
    }

}

extension LNURLWithdrawViewController: LNURLLoadingViewDelegate {

    func didTapGoToHome() {
        navigationController?.popToRootViewController(animated: true)
    }

}
