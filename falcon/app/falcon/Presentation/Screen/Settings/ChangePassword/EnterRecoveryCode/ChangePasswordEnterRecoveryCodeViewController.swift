//
//  ChangePasswordEnterRecoveryCodeViewController.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ChangePasswordEnterRecoveryCodeViewController: MUViewController {

    private var enterRCView: ChangePasswordEnterRecoveryCodeView!
    private lazy var presenter = instancePresenter(ChangePasswordEnterRecoveryCodePresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "password_change_enter_current"
    }

    override func loadView() {
        super.loadView()

        enterRCView = ChangePasswordEnterRecoveryCodeView(delegate: self)
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
        title = L10n.ChangePasswordEnterRecoveryCodeViewController.s1
        navigationItem.rightBarButtonItem = .stepCounter(step: 1, end: 3)
    }

}

// Keyboard actions
extension ChangePasswordEnterRecoveryCodeViewController {

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

extension ChangePasswordEnterRecoveryCodeViewController: ChangePasswordEnterRecoveryCodeViewDelegate {

    func didConfirmRecoveryCode(_ code: String) {
        presenter.requestChallengeAndSignIt(userInput: code)
    }

}

extension ChangePasswordEnterRecoveryCodeViewController: ChangePasswordEnterRecoveryCodePresenterDelegate {

    func invalidRecoveryCode() {
        enterRCView.wrongCode()
    }

    func setLoading(_ isLoading: Bool) {
        enterRCView.setButtonLoading(isLoading)
    }

    func pendingUpdateReceived(challengeType: String, updateUuid: String) {
        navigationController!.pushViewController(
            ChangePasswordVerifyViewController(challengeType: challengeType, pendingUpdateUuid: updateUuid),
            animated: true
        )
    }

}
