//
//  ActivateEmergencyKitViewController.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ActivateEmergencyKitViewController: MUViewController {

    private let verificationCode: String
    private let shareOption: String?
    private var activateView: ActivateEmergencyKitView!
    private let helpNavigationController = UINavigationController()

    fileprivate lazy var presenter = instancePresenter(ActivateEmergencyKitPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "emergency_kit_verify"
    }

    init(verificationCode: String, shareOption: String? = nil) {
        self.verificationCode = verificationCode
        self.shareOption = shareOption

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        activateView = ActivateEmergencyKitView(delegate: self)
        self.view = activateView

        displayActivationCodeInViewForTesting()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        setUpNavigation()
        presenter.setUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        activateView.showKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        title = L10n.ActivateEmergencyKitViewController.s1
    }

    private func displayActivationCodeInViewForTesting() {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            activateView.displayActivationCodeForTesting(verificationCode)
        }
        #endif
    }

}

extension ActivateEmergencyKitViewController: ActivateEmergencyKitViewDelegate {

    func verifyCode(_ code: String) {
        if code == verificationCode {
            presenter.reportExported(verificationCode: code)
            logEvent("emergency_kit_exported", parameters: ["share_option": shareOption ?? "unknown"])

            navigationController!.pushViewController(
                FeedbackViewController(feedback: FeedbackInfo.emergencyKit), animated: true
            )
        } else if presenter.isOld(code: code) {
            let firstDigitsOfOriginalCode = String(describing: verificationCode.prefix(2))
            activateView.oldCode(firstDigitsOfOriginalCode)
        } else {
            activateView.wrongCode()
        }
    }

    func helpLabelTap() {
        let helpVc = HelpEmergencyKitViewController()
        helpNavigationController.setViewControllers([helpVc], animated: true)
        navigationController!.present(helpNavigationController, animated: true)
    }

}

extension ActivateEmergencyKitViewController: ActivateEmergencyKitPresenterDelegate {}
