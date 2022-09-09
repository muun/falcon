//
//  ChangePasswordEnterNewViewController.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ChangePasswordEnterNewViewController: MUViewController {

    private var changePasswordView: ChangePasswordEnterNewView!
    private lazy var presenter = instancePresenter(ChangePasswordEnterNewPresenter.init, delegate: self)
    private var pendingUpdateUuid: String

    override var screenLoggingName: String {
        return "password_change_end"
    }

    override func loadView() {
        super.loadView()

        changePasswordView = ChangePasswordEnterNewView(delegate: self)
        self.view = changePasswordView
    }

    init(pendingUpdateUuid: String) {
        self.pendingUpdateUuid = pendingUpdateUuid

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
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
        title = L10n.ChangePasswordEnterNewViewController.s1
        navigationItem.rightBarButtonItem = .stepCounter(step: 3, end: 3)

        let backImage = Constant.Images.back
        let newBackButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: .backButtonTouched)
        navigationItem.leftBarButtonItem = newBackButton
    }

    @objc func presentAlertView() {
        let alert = UIAlertController(title: L10n.ChangePasswordEnterNewViewController.s2,
                                      message: L10n.ChangePasswordEnterNewViewController.s3,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ChangePasswordEnterNewViewController.s4,
                                      style: .default,
                                      handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.ChangePasswordEnterNewViewController.s5,
                                      style: .destructive,
                                      handler: { _ in
            self.logEvent("password_change_aborted")
            self.navigationController!.popToRootViewController(animated: true)
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.present(alert, animated: true)
    }

}

// Keyboard actions
extension ChangePasswordEnterNewViewController {

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

extension ChangePasswordEnterNewViewController: ChangePasswordEnterNewViewDelegate {
    func didEnterNewPassword(_ password: String) {
        presenter.finishPasswordChange(password: password, updateUuid: pendingUpdateUuid)
    }
}

extension ChangePasswordEnterNewViewController: ChangePasswordEnterNewPresenterDelegate {

    func passwordChanged() {
        logEvent("password_changed")
        navigationController!.pushViewController(
            FeedbackViewController(feedback: FeedbackInfo.changePassword),
            animated: true
        )
    }

    func setLoading(_ isLoading: Bool) {
        changePasswordView.setButtonLoading(isLoading)
    }

}

fileprivate extension Selector {

    static let backButtonTouched = #selector(ChangePasswordEnterNewViewController.presentAlertView)

}
