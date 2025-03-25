//
//  RecoveryCodePrimingViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 02/09/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit


class RecoveryCodePrimingViewController: MUViewController {

    @IBOutlet fileprivate weak var buttonView: ButtonView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var subtitleLabel: UILabel!
    fileprivate weak var errorViewRetryButton: ButtonView?
    fileprivate var errorView: ErrorView?

    fileprivate lazy var presenter = instancePresenter(RecoveryCodePrimingPresenter.init,
                                                       delegate: self)

    private var wording: SetUpRecoveryCodeWording

    override var screenLoggingName: String {
        return "recovery_code_priming"
    }

    init(wording: SetUpRecoveryCodeWording) {
        self.wording = wording

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.setUp()

        setUpNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
    }

    private func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = ""
    }

    private func setUpView() {
        setUpLabels()
        setUpButton()

        makeViewTestable()

        animateView()
    }

    private func setUpLabels() {
        titleLabel.text = wording.primingTitle()
        titleLabel.style = .title
        titleLabel.alpha = 0

        subtitleLabel.style = .description
        subtitleLabel.attributedText = wording.primingDescription()
        subtitleLabel.alpha = 0
    }

    private func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.RecoveryCodePrimingViewController.s1
        buttonView.isEnabled = true
        buttonView.alpha = 0
    }

    fileprivate func animateView() {
        titleLabel.animate(direction: .topToBottom, duration: .short)
        subtitleLabel.animate(direction: .topToBottom, duration: .short)

        buttonView.animate(direction: .bottomToTop, duration: .short, delay: .short)
    }
}

extension RecoveryCodePrimingViewController: ButtonViewDelegate {
    func button(didPress button: ButtonView) {
        presenter.onContinueButtonTapped()
    }
}

extension RecoveryCodePrimingViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.PrimingRecoveryCodePage

    func makeViewTestable() {
        self.makeViewTestable(view, using: .root)
        self.makeViewTestable(buttonView, using: .next)
    }
}

extension RecoveryCodePrimingViewController: ErrorViewDelegate {
    func secondaryButtonTouched() {
        navigationController?.popToRootViewController(animated: true)
    }

    func retryTouched(button: ButtonView) {
        errorViewRetryButton = button
        presenter.retryTappedAfterError()
    }

    func logErrorView(_ name: String, params: [String: Any]?) {
        logScreen(name, parameters: params)
    }
}

extension RecoveryCodePrimingViewController: RecoveryCodePrimingPresenterDelegate {
    func goToNextScreen(recoveryCode: RecoveryCode) {
        navigationController?.pushViewController(GenerateRecoveryCodeViewController(wording: wording,
                                                                                    recoveryCode: recoveryCode),
                                                 animated: true)
    }

    func continueButtonIs(loading: Bool) {
        buttonView.isLoading = loading
        errorViewRetryButton?.isLoading = loading
    }

    func showStartRecoveryCodeSetupError() {
        navigationController?.setNavigationBarHidden(true, animated: true)

        if errorView == nil {
            errorView = ErrorView()
            errorView?.delegate = self
            errorView?.model = SetupRecoveryCodeError.failedToStartSetup
            errorView?.addTo(self.view)
        }

        self.view.gestureRecognizers?.removeAll()
    }
}
