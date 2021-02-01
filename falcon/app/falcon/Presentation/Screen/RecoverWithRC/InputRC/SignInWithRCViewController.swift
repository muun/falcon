//
//  SignInWithRCViewController.swift
//  falcon
//
//  Created by Manu Herrera on 09/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class SignInWithRCViewController: MUViewController {

    private var enterRCView: SignInWithRCView!
    private lazy var presenter = instancePresenter(SignInWithRCPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "sign_in_with_rc"
    }

    override func loadView() {
        enterRCView = SignInWithRCView(delegate: self)
        self.view = enterRCView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        addKeyboardObservers()
        setUpNavigation()
        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardObservers()
        presenter.tearDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        enterRCView.animate()
    }

    fileprivate func setUpNavigation() {
        title = L10n.SignInWithRCViewController.s1
    }

}

//Keyboard actions
extension SignInWithRCViewController {

    override func keyboardWillHide(notification: NSNotification) {
        animateBottomMarginTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateBottomMarginTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateBottomMarginTransition(height: CGFloat) {
        enterRCView.animateBottomMarginTransition(height: height)
    }

}

extension SignInWithRCViewController: SignInWithRCViewDelegate {

    func tapOnIncorrectRecoveryCodeLabel() {
        // Go back to the email screen
        navigationController!.popViewController(animated: true)
    }

    func moreInfoTouched() {
        let moreInfo = BottomDrawerInfo.whatIsTheRecoveryCodeSignIn(rcSetupDate: nil)
        let overlayVc = BottomDrawerOverlayViewController(info: moreInfo)

        navigationController!.present(overlayVc, animated: true)
    }

    func didConfirmRecoveryCode(_ code: String) {
        presenter.createSession(recoveryCode: code)
    }

}

extension SignInWithRCViewController: SignInWithRCPresenterDelegate {

    func invalidRecoveryCodeVersion() {
        enterRCView.wrongRecoveryCodeVersion()
    }

    func recoveryCodeNotSetUp() {
        enterRCView.wrongCode()
    }

    func setLoading(_ isLoading: Bool) {
        enterRCView.setButtonLoading(isLoading)
    }

    func loggedIn() {
        logEvent("sign_in_successful", parameters: ["type": "recovery_code"])

        navigationController!.pushViewController(
            PinViewController(state: .choosePin, isExistingUser: true), animated: true
        )
    }

    func needsEmailVerify(obfuscatedEmail: String) {
        navigationController!.pushViewController(
            SignInWithRCVerifyEmailViewController(
                obfuscatedEmail: obfuscatedEmail,
                recoveryCode: presenter.recoveryCode
            ),
            animated: true
        )
    }

}
