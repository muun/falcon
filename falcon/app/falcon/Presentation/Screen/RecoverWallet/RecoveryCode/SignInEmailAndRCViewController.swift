//
//  SignInEmailAndRCViewController.swift
//  falcon
//
//  Created by Manu Herrera on 30/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class SignInEmailAndRCViewController: MUViewController {

    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet private weak var recoveryView: RecoveryView!
    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet private weak var errorLabel: UILabel!

    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(SignInEmailAndRCPresenter.init, delegate: self)
    private var recoveryCode: RecoveryCode?
    private let sessionOk: CreateSessionOk

    override var screenLoggingName: String {
        return "sign_in_input_recovery_code"
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

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.SignInEmailAndRCViewController.s1
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpRecoveryView()
        setUpButton()

        animateView()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.SignInEmailAndRCViewController.s2

        if let setupDate = sessionOk.recoveryCodeSetupDate {
            let dateText = setupDate.date()
            let hintText = L10n.SignInEmailAndRCViewController.s3(dateText)
            let desc = hintText
                .attributedForDescription()
                .set(bold: dateText, color: Asset.Colors.title.color)
                .set(underline: L10n.SignInEmailAndRCViewController.s4, color: Asset.Colors.muunBlue.color)
            titleAndDescriptionView.descriptionText = desc
        } else {
            let hintText = L10n.SignInEmailAndRCViewController.s5
                .attributedForDescription()
                .set(underline: L10n.SignInEmailAndRCViewController.s4, color: Asset.Colors.muunBlue.color)

            titleAndDescriptionView.descriptionText = hintText

        }

        titleAndDescriptionView.delegate = self

        errorLabel.isHidden = true
        errorLabel.style = .error
        errorLabel.text = L10n.SignInEmailAndRCViewController.s7
    }

    fileprivate func setUpRecoveryView() {
        recoveryView.delegate = self
        recoveryView.alpha = 0
        recoveryView.isLoading = false
    }

    fileprivate func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.SignInEmailAndRCViewController.s8
        buttonView.isEnabled = false
        buttonView.alpha = 0
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate {
            self.recoveryView.animate(direction: .topToBottom, duration: .short) {
                self.errorLabel.animate(direction: .topToBottom, duration: .short)
            }
        }

        buttonView.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
    }

}

extension SignInEmailAndRCViewController: TitleAndDescriptionViewDelegate {

    func descriptionTouched() {
        let moreInfo = BottomDrawerInfo.whatIsTheRecoveryCodeSignIn(
            rcSetupDate: sessionOk.recoveryCodeSetupDate
        )
        let overlayVc = BottomDrawerOverlayViewController(info: moreInfo)

        navigationController!.present(overlayVc, animated: true)
    }

}

//Keyboard actions
extension SignInEmailAndRCViewController {

    override func keyboardWillHide(notification: NSNotification) {
        animateScrollTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateScrollTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateScrollTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.buttonBottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension SignInEmailAndRCViewController: SignInEmailAndRCPresenterDelegate {

    func setLoading(_ isLoading: Bool) {
        recoveryView.isLoading = isLoading
    }

    func keySetResponseReceived(keySet: KeySet) {
        logEvent("sign_in_successful", parameters: ["type": "email_and_recovery_code"])

        navigationController!.pushViewController(
            PinViewController(state: .choosePin, isExistingUser: true), animated: true
        )
    }

    func invalidCode() {
        errorLabel.isHidden = false
    }
}

extension SignInEmailAndRCViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {

        guard let recoveryCode = recoveryCode else {
            Logger.log(.err, "didn't have a recovery code")
            return
        }
        errorLabel.isHidden = true

        presenter.requestChallengeAndSignIt(code: recoveryCode)
    }

}

extension SignInEmailAndRCViewController: RecoveryViewDelegate {

    func recoveryViewDidChange(_ recoveryView: RecoveryView, code: RecoveryCode?) {

        guard let code = code else {
            buttonView.isEnabled = false
            errorLabel.isHidden = true
            return
        }

        recoveryCode = code
        buttonView.isEnabled = true
    }

}

extension SignInEmailAndRCViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.RecoveryCodePage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(recoveryView, using: .codeView)
        makeViewTestable(buttonView, using: .continueButton)
    }

}
