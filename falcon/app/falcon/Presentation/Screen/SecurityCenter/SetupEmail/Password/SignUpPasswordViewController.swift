//
//  SignUpPasswordViewController.swift
//  falcon
//
//  Created by Manu Herrera on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

enum CreatePasswordState {
    case inputPassword
    case confirmPassword
}

class SignUpPasswordViewController: MUViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet private weak var firstTextInputView: TextInputView!
    @IBOutlet private weak var button: ButtonView!
    @IBOutlet private weak var secondTextInputView: TextInputView!

    @IBOutlet private weak var buttonContainerBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(SignUpPasswordPresenter.init, delegate: self)
    private var status: CreatePasswordState = .inputPassword
    private var wording: SetUpEmailWording

    override var screenLoggingName: String {
        return "sign_up_password"
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        _ = firstTextInputView.becomeFirstResponder()

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
        navigationItem.rightBarButtonItem = .stepCounter(step: 3, end: 4)

        let backImage = Constant.Images.back
        let newBackButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: .backButtonTouched)
        navigationItem.leftBarButtonItem = newBackButton
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpTextViews()
        setUpButton()

        makeViewTestable()

        animateView()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.SignUpPasswordViewController.s1
        let desc = L10n.SignUpPasswordViewController.s2
            .attributedForDescription()
        titleAndDescriptionView.descriptionText = desc
    }

    fileprivate func setUpTextViews() {
        firstTextInputView.delegate = self
        firstTextInputView.bottomLabel = L10n.SignUpPasswordViewController.s3
        firstTextInputView.topLabel = L10n.SignUpPasswordViewController.s4
        firstTextInputView.isPassword = true
        firstTextInputView.placeholder = L10n.SignUpPasswordViewController.s5
        firstTextInputView.alpha = 0

        secondTextInputView.delegate = self
        secondTextInputView.bottomLabel = L10n.SignUpPasswordViewController.s6
        secondTextInputView.topLabel = L10n.SignUpPasswordViewController.s7
        secondTextInputView.isPassword = true
        secondTextInputView.placeholder = L10n.SignUpPasswordViewController.s5
        secondTextInputView.alpha = 0
        secondTextInputView.isHidden = true
    }

    fileprivate func setUpButton() {
        button.delegate = self
        button.buttonText = L10n.SignUpPasswordViewController.s9
        button.isEnabled = false
        button.alpha = 0
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate {
            self.firstTextInputView.animate(direction: .topToBottom, duration: .short)
        }

        button.animate(direction: .bottomToTop, duration: .medium, delay: .medium)
    }

    @objc func presentAlertView() {
        let msg = L10n.SignUpPasswordViewController.s10
        let alert = UIAlertController(title: L10n.SignUpPasswordViewController.s11, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.SignUpPasswordViewController.s12, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.SignUpPasswordViewController.s13, style: .destructive, handler: { _ in
            self.logEvent("email_setup_aborted")
            self.navigationController!.popTo(type: SecurityCenterViewController.self)
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.present(alert, animated: true)
    }

}

extension SignUpPasswordViewController: SignUpPasswordPresenterDelegate {}

//Keyboard actions
extension SignUpPasswordViewController {

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
            self.buttonContainerBottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension SignUpPasswordViewController: TextInputViewDelegate {

    func onTextChange(textInputView: TextInputView, text: String) {
        if textInputView == firstTextInputView {
            button.isEnabled = presenter.isValidPassword(text)
        } else if textInputView == secondTextInputView {
            button.isEnabled = presenter.isValidPassword(text) && presenter.isValidPassword(firstTextInputView.text)
        }
    }

}

extension SignUpPasswordViewController: ButtonViewDelegate {

    enum PasswordErrorParam: String {
        case did_not_match
    }

    func button(didPress button: ButtonView) {
        if status == .inputPassword {
            status = .confirmPassword
            button.isEnabled = false
            button.buttonText = L10n.SignUpPasswordViewController.s14
            scrollView.contentOffset = secondTextInputView.frame.origin

            secondTextInputView.isHidden = false
            secondTextInputView.animate(direction: .topToBottom, duration: .short)
            _ = secondTextInputView.becomeFirstResponder()

        } else if status == .confirmPassword {
            if presenter.passwordsMatch(first: firstTextInputView.text, second: secondTextInputView.text) {
                view.endEditing(true)

                let vc = FinishEmailSetupViewController(passphrase: firstTextInputView.text, wording: wording)
                navigationController!.pushViewController(vc, animated: true)

            } else {
                logEvent("password", parameters: ["error": PasswordErrorParam.did_not_match.rawValue])
                secondTextInputView.setError(L10n.SignUpPasswordViewController.s6)
            }
        }

    }

}

extension SignUpPasswordViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SetUpPasswordPage

    func makeViewTestable() {
        self.makeViewTestable(self.view, using: .root)
        self.makeViewTestable(self.firstTextInputView, using: .firstTextInputView)
        self.makeViewTestable(self.secondTextInputView, using: .secondTextInputView)
        self.makeViewTestable(self.button, using: .continueView)
    }

}

fileprivate extension Selector {

    static let backButtonTouched = #selector(SignUpPasswordViewController.presentAlertView)

}
