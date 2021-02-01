//
//  ChangePasswordEnterCurrentViewController.swift
//  falcon
//
//  Created by Manu Herrera on 27/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ChangePasswordEnterCurrentViewController: MUViewController {

    private var changePasswordView: ChangePasswordEnterCurrentView!
    private lazy var presenter = instancePresenter(ChangePasswordEnterCurrentPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "password_change_enter_current"
    }

    override func loadView() {
        super.loadView()

        changePasswordView = ChangePasswordEnterCurrentView(delegate: self)
        self.view = changePasswordView
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

        changePasswordView.makePasswordInputFirstResponder()
    }

    fileprivate func setUpNavigation() {
        title = L10n.ChangePasswordEnterCurrentViewController.s1
        navigationItem.rightBarButtonItem = .stepCounter(step: 1, end: 3)
        navigationController!.setNavigationBarHidden(false, animated: true)
    }

}

//Keyboard actions
extension ChangePasswordEnterCurrentViewController {

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
        changePasswordView.animateBottomMarginTransition(height: height)
    }

}

extension ChangePasswordEnterCurrentViewController: ChangePasswordEnterCurrentViewDelegate {
    func didConfirm(_ password: String) {
        presenter.requestChallengeAndSignIt(userInput: password)
    }

    func didTapForgotPasswordButton() {
        if presenter.hasRecoveryCode() {
            navigationController!.pushViewController(ChangePasswordEnterRecoveryCodeViewController(), animated: true)
        } else {
            navigationController!.pushViewController(RecoveryCodeMissingViewController(), animated: true)
        }
    }
}

extension ChangePasswordEnterCurrentViewController: ChangePasswordEnterCurrentPresenterDelegate {

    func setLoading(_ isLoading: Bool) {
        changePasswordView.setButtonLoading(isLoading)
    }

    func pendingUpdateReceived(challengeType: String, updateUuid: String) {
        navigationController!.pushViewController(
            ChangePasswordVerifyViewController(challengeType: challengeType, pendingUpdateUuid: updateUuid),
            animated: true
        )
    }

    func invalidPassword() {
        changePasswordView.setInvalidPassword()
    }

}
