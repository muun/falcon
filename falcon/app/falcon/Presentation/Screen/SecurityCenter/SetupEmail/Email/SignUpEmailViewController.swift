//
//  SignUpEmailViewController.swift
//  falcon
//
//  Created by Manu Herrera on 17/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class SignUpEmailViewController: MUViewController {

    @IBOutlet private weak var textInputView: TextInputView!
    @IBOutlet private weak var button: ButtonView!
    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var helpLabel: UILabel!

    private var wording: SetUpEmailWording

    fileprivate lazy var presenter = instancePresenter(SignUpEmailPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "sign_up_email"
    }

    init(wording: SetUpEmailWording) {
        self.wording = wording

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

        title = wording.navigationTitle()

        navigationItem.rightBarButtonItem = .stepCounter(step: 1, end: 4)
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpTextfield()
        setUpButtons()

        animateView()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = wording.enterEmailTitle()
        titleAndDescriptionView.descriptionText = wording.enterEmailDescription()
        titleAndDescriptionView.delegate = self

        helpLabel.style = .description
        let text = L10n.SignUpEmailViewController.s1
        helpLabel.attributedText = text
            .set(font: helpLabel.font)
            .set(underline: text, color: Asset.Colors.muunBlue.color)
        helpLabel.isHidden = true

        helpLabel.isUserInteractionEnabled = true
        helpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .helpTouched))
    }

    fileprivate func animateView() {
        self.titleAndDescriptionView.animate {
            self.textInputView.animate(direction: .topToBottom, duration: .short)
        }

        button.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
    }

    fileprivate func setUpTextfield() {
        textInputView.delegate = self
        textInputView.bottomLabel = ""
        textInputView.topLabel = L10n.SignUpEmailViewController.s2
        textInputView.isPassword = false
        textInputView.placeholder = L10n.SignUpEmailViewController.s3
        textInputView.alpha = 0
        _ = textInputView.becomeFirstResponder()
    }

    fileprivate func setUpButtons() {
        setUpConfirmButton()
    }

    fileprivate func setUpConfirmButton() {
        button.delegate = self
        button.buttonText = L10n.SignUpEmailViewController.s4
        button.isEnabled = presenter.isValidEmail(testStr: textInputView.text)
        button.alpha = 0
    }

    @objc func helpTouched() {
        view.endEditing(true)
        let nc = UINavigationController(rootViewController: EmailAlreadyUsedViewController())
        navigationController!.present(nc, animated: true)
    }

}

//Keyboard actions
extension SignUpEmailViewController {

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

extension SignUpEmailViewController: TextInputViewDelegate {

    func onTextChange(textInputView: TextInputView, text: String) {
        helpLabel.isHidden = true
        button.isEnabled = presenter.isValidEmail(testStr: text)
    }

}

extension SignUpEmailViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        view.endEditing(true)
        helpLabel.isHidden = true

        presenter.requestChallenge(email: textInputView.text.trimmingCharacters(in: .whitespaces))
    }

}

extension SignUpEmailViewController: SignUpEmailPresenterDelegate {

    enum EmailErrorParam: String {
        case already_used
        case invalid
    }

    func responseOkReceived() {
        navigationController!.pushViewController(SignUpVerifyEmailViewController(wording: wording), animated: true)
    }

    func invalidEmail() {
        logEvent("email", parameters: ["type": EmailErrorParam.invalid.rawValue])

        textInputView.setError("Invalid Email")
    }

    func setLoading(_ isLoading: Bool) {
        button.isLoading = isLoading
        textInputView.isUserInteractionEnabled = !isLoading
        titleAndDescriptionView.isUserInteractionEnabled = !isLoading
    }

    func emailAlreadyUsed() {
        logEvent("email", parameters: ["type": EmailErrorParam.already_used.rawValue])

        textInputView.setError(L10n.SignUpEmailViewController.s5)
        helpLabel.isHidden = false
        helpLabel.animate(direction: .topToBottom, duration: .short)
    }

}

extension SignUpEmailViewController: TitleAndDescriptionViewDelegate {

    func descriptionTouched() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.whyEmail)
        navigationController!.present(overlayVc, animated: true)
    }

}

extension SignUpEmailViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SetEmailBackUpPage

    func makeViewTestable() {
        self.makeViewTestable(self.view, using: .root)
        self.makeViewTestable(self.textInputView, using: .textInputView)
        self.makeViewTestable(self.button, using: .continueView)
    }

}

fileprivate extension Selector {

    static let helpTouched = #selector(SignUpEmailViewController.helpTouched)

}
