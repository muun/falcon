//
//  ConfirmRecoveryCodeViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class FinishRecoveryCodeSetupViewController: MUViewController {

    @IBOutlet fileprivate weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet fileprivate weak var firstCheckView: CheckView!
    @IBOutlet fileprivate weak var secondCheckView: CheckView!
    @IBOutlet fileprivate weak var buttonView: ButtonView!
    fileprivate weak var errorViewRetryButton: ButtonView?
    fileprivate var errorView: ErrorView?

    fileprivate lazy var presenter = instancePresenter(FinishRecoveryCodeSetupPresenter.init,
                                                       delegate: self,
                                                       state: recoveryCode)

    fileprivate var recoveryCode: RecoveryCode!
    private var wording: SetUpRecoveryCodeWording

    override var screenLoggingName: String {
        return "finish_recovery_code_setup"
    }

    init(code: RecoveryCode, wording: SetUpRecoveryCodeWording) {
        self.recoveryCode = code
        self.wording = wording

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpChecks()
        setUpButton()

        animateView()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.FinishRecoveryCodeSetupViewController.s1
        titleAndDescriptionView.descriptionText = nil
    }

    fileprivate func setUpChecks() {
        firstCheckView.labelText = wording.firstUnderstandingCheck()
        firstCheckView.delegate = self
        firstCheckView.alpha = 0

        secondCheckView.labelText = wording.secondUnderstandingCheck()
        secondCheckView.delegate = self
        secondCheckView.alpha = 0
    }

    fileprivate func setUpButton() {
        buttonView.isEnabled = false
        buttonView.buttonText = L10n.FinishRecoveryCodeSetupViewController.s2
        buttonView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.setUp()
        setUpNavigation()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        navigationItem.rightBarButtonItem = .stepCounter(step: 3, end: 3)
        title = wording.navigationTitle()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate()
        firstCheckView.animate(direction: .topToBottom, duration: .short)
        secondCheckView.animate(direction: .topToBottom, duration: .short)
    }
}

extension FinishRecoveryCodeSetupViewController: FinishRecoveryCodeSetupPresenterDelegate {
    func challengeSuccess() {
        logEvent("recovery_code_set_up")

        // Determine if we are on change password flow by checking the viewcontrollers on the stack
        let isChangePasswordFlow = navigationController!.viewControllers.contains(
            where: { return $0 is ChangePasswordEnterCurrentViewController }
        )
        // When finished, pop to change password flow or security center (depending on the initial flow)
        let popToVc = isChangePasswordFlow
        ? ChangePasswordEnterCurrentViewController.self
        : SecurityCenterViewController.self

        navigationController!.pushViewController(
            FeedbackViewController(feedback: FeedbackInfo.recoveryCodeSetupSuccess(popTo: popToVc, wording: wording)),
            animated: true
        )
    }

    func showFinishErrorSetupError() {
        navigationController?.setNavigationBarHidden(true, animated: true)

        if errorView == nil {
            errorView = ErrorView()
            errorView?.delegate = self
            errorView?.model = SetupRecoveryCodeError.failedToFinishSetup
            errorView?.addTo(self.view)
        }

        self.view.gestureRecognizers?.removeAll()
    }

    func finishButtonIs(loading: Bool) {
        buttonView.isLoading = loading
        errorViewRetryButton?.isLoading = loading
    }
}

extension FinishRecoveryCodeSetupViewController: ErrorViewDelegate {
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

extension FinishRecoveryCodeSetupViewController: CheckViewDelegate {

    func onCheckChanged(checked: Bool) {
        buttonView.isEnabled = firstCheckView.isChecked && secondCheckView.isChecked
    }

}

extension FinishRecoveryCodeSetupViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        button.isLoading = true
        presenter.confirm()
    }

}

extension FinishRecoveryCodeSetupViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.ConfirmRecoveryCodePage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(firstCheckView, using: .firstCheck)
        makeViewTestable(secondCheckView, using: .secondCheck)
        makeViewTestable(buttonView, using: .continueButton)
    }

}
