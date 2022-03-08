//
//  SignInEmailViewController.swift
//  falcon
//
//  Created by Manu Herrera on 17/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class SignInEmailViewController: MUViewController {

    @IBOutlet private weak var textInputView: TextInputView!
    @IBOutlet private weak var button: ButtonView!
    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet private weak var useRecoveryCodeButton: LinkButtonView!

    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(SignInEmailPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "sign_in_email"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        addKeyboardObservers()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardObservers()

        presenter.tearDown()
    }

    private func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = L10n.SignInEmailViewController.s1
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpTextfield()
        setUpButtons()

        animateView()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.SignInEmailViewController.s2
        titleAndDescriptionView.descriptionText = L10n.SignInEmailViewController.s3
            .attributedForDescription()
    }

    fileprivate func animateView() {
        self.titleAndDescriptionView.animate {
            self.textInputView.animate(direction: .topToBottom, duration: .short)
            self.useRecoveryCodeButton.animate(direction: .topToBottom, duration: .short)
        }

        button.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
    }

    fileprivate func setUpTextfield() {
        textInputView.delegate = self
        textInputView.bottomLabel = ""
        textInputView.topLabel = L10n.SignInEmailViewController.s4
        textInputView.isPassword = false
        textInputView.placeholder = L10n.SignInEmailViewController.s5
        textInputView.alpha = 0
        _ = textInputView.becomeFirstResponder()
    }

    fileprivate func setUpButtons() {
        button.delegate = self
        button.buttonText = L10n.SignInEmailViewController.s6
        button.isEnabled = presenter.isValidEmail(testStr: textInputView.text)
        button.alpha = 0

        useRecoveryCodeButton.delegate = self
        useRecoveryCodeButton.buttonText = L10n.SignInEmailViewController.s7
        useRecoveryCodeButton.isEnabled = true
        useRecoveryCodeButton.alpha = 0
    }

}

// Keyboard actions
extension SignInEmailViewController {

    override func keyboardWillHide(notification: NSNotification) {
        animateButtonTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateButtonTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateButtonTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.buttonBottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension SignInEmailViewController: TextInputViewDelegate {

    func onTextChange(textInputView: TextInputView, text: String) {
        button.isEnabled = presenter.isValidEmail(testStr: text)
    }

}

extension SignInEmailViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        view.endEditing(true)

        presenter.createSession(email: textInputView.text.trimmingCharacters(in: .whitespaces))
    }

}

extension SignInEmailViewController: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        view.endEditing(true)
        navigationController!.pushViewController(SignInWithRCViewController(), animated: true)
    }

}

extension SignInEmailViewController: SignInEmailPresenterDelegate {

    func invalidEmail() {
        textInputView.setError("Invalid Email")
    }

    func setLoading(_ isLoading: Bool) {
        button.isLoading = isLoading
        textInputView.isUserInteractionEnabled = !isLoading
        titleAndDescriptionView.isUserInteractionEnabled = !isLoading
        useRecoveryCodeButton.isEnabled = !isLoading
    }

    func sessionResponseReceived(sessionOk: CreateSessionOk) {
        let vc = SignInPasswordViewController(sessionOk)
        navigationController!.pushViewController(SignInAuthorizeEmailViewController(nextVc: vc), animated: true)
    }

    func userNotRegistered() {
        textInputView.setError(L10n.SignInEmailViewController.s8)
    }

}

extension SignInEmailViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SignInEmailPage

    func makeViewTestable() {
        self.makeViewTestable(self.view, using: .root)
        self.makeViewTestable(self.textInputView, using: .textInputView)
        self.makeViewTestable(self.button, using: .continueView)
        self.makeViewTestable(self.useRecoveryCodeButton, using: .signInWithRC)
    }

}
