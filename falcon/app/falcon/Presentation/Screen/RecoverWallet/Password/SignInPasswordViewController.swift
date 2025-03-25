//
//  SignInPasswordViewController.swift
//  falcon
//
//  Created by Manu Herrera on 30/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit


class SignInPasswordViewController: MUViewController {

    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet private weak var textInputView: TextInputView!
    @IBOutlet private weak var button: ButtonView!
    @IBOutlet private weak var forgotPasswordButton: LinkButtonView!

    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(SignInPasswordPresenter.init, delegate: self)

    private let sessionOk: CreateSessionOk

    override var screenLoggingName: String {
        return "sign_in_password"
    }

    init(_ sessionOk: CreateSessionOk) {
        self.sessionOk = sessionOk

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
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
        title = L10n.SignInPasswordViewController.s1

        let backImage = Constant.Images.back
        let newBackButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: .backButtonTouched)
        navigationItem.leftBarButtonItem = newBackButton
    }

    private func setUpView() {
        setUpLabels()
        setUpTextfield()
        setUpButtons()

        animateView()
    }

    private func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.SignInPasswordViewController.s2
        titleAndDescriptionView.descriptionText = nil
    }

    private func setUpTextfield() {
        textInputView.delegate = self
        textInputView.bottomLabel = ""
        textInputView.topLabel = L10n.SignInPasswordViewController.s3
        textInputView.bottomLabel = L10n.SignInPasswordViewController.s4
        textInputView.isPassword = true
        textInputView.placeholder = L10n.SignInPasswordViewController.s3
        textInputView.alpha = 0
        _ = textInputView.becomeFirstResponder()
    }

    private func setUpButtons() {
        button.delegate = self
        button.buttonText = L10n.SignInPasswordViewController.s6
        button.isEnabled = false
        button.alpha = 0

        forgotPasswordButton.delegate = self
        forgotPasswordButton.buttonText = L10n.SignInPasswordViewController.s7
        forgotPasswordButton.isEnabled = true
        forgotPasswordButton.alpha = 0
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate {
            self.textInputView.animate(direction: .topToBottom, duration: .short)
        }

        button.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
        forgotPasswordButton.animate(direction: .topToBottom, duration: .medium, delay: .short3)
    }

    @objc func presentAlertView() {
        let alert = UIAlertController(title: L10n.SignInPasswordViewController.s8,
                                      message: L10n.SignInPasswordViewController.s9,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.SignInPasswordViewController.s10, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.SignInPasswordViewController.s11, style: .destructive, handler: { _ in
            self.logEvent("sign_in_aborted")
            self.navigationController!.popToRootViewController(animated: true)
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.present(alert, animated: true)
    }

}

// Keyboard actions
extension SignInPasswordViewController {

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

extension SignInPasswordViewController: TextInputViewDelegate {

    func onTextChange(textInputView: TextInputView, text: String) {
        button.isEnabled = presenter.isValidPassword(text)
    }

}

extension SignInPasswordViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        view.endEditing(true)

        presenter.requestChallengeAndSignIt(userInput: textInputView.text)
    }

}

extension SignInPasswordViewController: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        if sessionOk.canUseRecoveryCode {
            view.endEditing(true)
            navigationController!.pushViewController(SignInEmailAndRCViewController(sessionOk), animated: true)
        } else {
            let moreInfo = BottomDrawerInfo.forgottenPassword(rcSetupDate: sessionOk.passwordSetupDate)
            let overlayVc = BottomDrawerOverlayViewController(info: moreInfo)
            navigationController!.present(overlayVc, animated: true)
        }
    }

}

extension SignInPasswordViewController: SignInPasswordPresenterDelegate {

    enum PasswordErrorParam: String {
        case incorrect
    }

    func keySetResponseReceived(keySet: KeySet) {
        logEvent("sign_in_successful", parameters: ["type": "password"])

        navigationController!.pushViewController(
            PinViewController(state: .choosePin, isExistingUser: true), animated: true
        )
    }

    func setLoading(_ isLoading: Bool) {
        button.isLoading = isLoading
    }

    func invalidPassword() {
        logEvent("password", parameters: ["error": PasswordErrorParam.incorrect.rawValue])
        textInputView.setError(L10n.SignInPasswordViewController.s12)
    }

}

extension SignInPasswordViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SignInPasswordPage

    func makeViewTestable() {
        self.makeViewTestable(self.view, using: .root)
        self.makeViewTestable(self.textInputView, using: .textInputView)
        self.makeViewTestable(self.button, using: .continueView)
        self.makeViewTestable(self.forgotPasswordButton, using: .forgotPasswordButton)
    }

}

fileprivate extension Selector {

    static let backButtonTouched = #selector(SignInPasswordViewController.presentAlertView)

}
