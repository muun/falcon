//
//  ActivateEmergencyKitViewController.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ActivateEmergencyKitViewController: MUViewController {

    private let kit: EmergencyKit
    private let shareOption: String?
    private var activateView: ActivateEmergencyKitView!
    private let helpNavigationController = UINavigationController()
    private let flow: EmergencyKitFlow

    fileprivate lazy var presenter = instancePresenter(ActivateEmergencyKitPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "emergency_kit_verify"
    }

    init(kit: EmergencyKit, shareOption: String? = nil, flow: EmergencyKitFlow) {
        self.kit = kit
        self.shareOption = shareOption
        self.flow = flow

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

        switch flow {
        case .export:
            title = L10n.ActivateEmergencyKitViewController.s1

        case .update:
            ()
        }
    }

    private func displayActivationCodeInViewForTesting() {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            activateView.displayActivationCodeForTesting(kit.verificationCode)
        }
        #endif
    }

}

extension ActivateEmergencyKitViewController: ActivateEmergencyKitViewDelegate {

    func verifyCode(_ code: String) {
        if code == kit.verificationCode {
            showLoading("")
            presenter.reportExported(kit: kit)
            logEvent("emergency_kit_exported", parameters: ["share_option": shareOption ?? "unknown"])
        } else if presenter.isOld(code: code) {
            let firstDigitsOfOriginalCode = String(describing: kit.verificationCode.prefix(2))
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

extension ActivateEmergencyKitViewController: ActivateEmergencyKitPresenterDelegate {

    func reported() {
        navigationController!.pushViewController(
                FeedbackViewController(feedback: flow.successFeedback), animated: true
        )
    }
}
