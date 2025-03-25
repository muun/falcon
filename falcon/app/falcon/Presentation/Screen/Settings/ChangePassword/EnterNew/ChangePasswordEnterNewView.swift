//
//  ChangePasswordEnterNewView.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit


protocol ChangePasswordEnterNewViewDelegate: AnyObject {
    func didEnterNewPassword(_ password: String)
}

final class ChangePasswordEnterNewView: MUView, PresenterInstantior {

    private var contentVerticalStack: UIStackView!
    private var titleAndDescriptionView: TitleAndDescriptionView!
    private var firstPasswordInput: TextInputView!
    private var secondPasswordInput: TextInputView!
    private var agreeChangePasswordCheck: CheckView!
    private var confirmButton: ButtonView!

    private lazy var presenter = instancePresenter(
        ChangePasswordNewViewPresenter.init,
        delegate: self
    )
    private weak var delegate: ChangePasswordEnterNewViewDelegate?

    private var bottomMarginConstraint: NSLayoutConstraint!

    init(delegate: ChangePasswordEnterNewViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpButton()
        setUpContentStackView()

        makeViewTestable()
        presenter.setUp()
    }

    private func setUpContentStackView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        contentVerticalStack = UIStackView()
        contentVerticalStack.axis = .vertical
        contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.spacing = 24

        scrollView.addSubview(contentVerticalStack)
        NSLayoutConstraint.activate([
            contentVerticalStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentVerticalStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            contentVerticalStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: .sideMargin),
            contentVerticalStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -.sideMargin),
            contentVerticalStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        setUpTItleAndDescriptionView()
        setUpPasswordInputs()
    }

    private func setUpTItleAndDescriptionView() {
        titleAndDescriptionView = TitleAndDescriptionView()
        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        titleAndDescriptionView.titleText = L10n.ChangePasswordEnterNewView.s1
        titleAndDescriptionView.descriptionText = L10n.ChangePasswordEnterNewView.s2
            .attributedForDescription()
        titleAndDescriptionView.animate()
        contentVerticalStack.addArrangedSubview(titleAndDescriptionView)
    }

    private func setUpPasswordInputs() {
        firstPasswordInput = TextInputView()
        firstPasswordInput.translatesAutoresizingMaskIntoConstraints = false
        firstPasswordInput.isPassword = true
        firstPasswordInput.topLabel = L10n.ChangePasswordEnterNewView.s3
        firstPasswordInput.bottomLabel = L10n.ChangePasswordEnterNewView.s4
        firstPasswordInput.delegate = self
        contentVerticalStack.addArrangedSubview(firstPasswordInput)

        secondPasswordInput = TextInputView()
        secondPasswordInput.translatesAutoresizingMaskIntoConstraints = false
        secondPasswordInput.isPassword = true
        secondPasswordInput.topLabel = L10n.ChangePasswordEnterNewView.s3
        secondPasswordInput.bottomLabel = L10n.ChangePasswordEnterNewView.s6
        secondPasswordInput.delegate = self
        contentVerticalStack.addArrangedSubview(secondPasswordInput)

        agreeChangePasswordCheck = CheckView()
        agreeChangePasswordCheck.translatesAutoresizingMaskIntoConstraints = false
        agreeChangePasswordCheck.delegate = self
        agreeChangePasswordCheck.labelText = L10n.ChangePasswordEnterNewView.s8
        agreeChangePasswordCheck.alpha = 0
        contentVerticalStack.addArrangedSubview(agreeChangePasswordCheck)
    }

    private func setUpButton() {
        confirmButton = ButtonView()
        confirmButton.delegate = self
        confirmButton.buttonText = L10n.ChangePasswordEnterNewView.s7
        confirmButton.isEnabled = false

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        bottomMarginConstraint = NSLayoutConstraint(
            item: confirmButton!,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: layoutMarginsGuide,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )

        addSubview(confirmButton)
        NSLayoutConstraint.activate([
            bottomMarginConstraint,
            confirmButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    // MARK: - View Controller actions -

    func animateBottomMarginTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.bottomMarginConstraint.constant = -height

            self.layoutIfNeeded()
        }
    }

    func setButtonLoading(_ isLoading: Bool) {
        confirmButton.isLoading = isLoading
    }

    func makePasswordInputFirstResponder() {
        _ = firstPasswordInput.becomeFirstResponder()
    }
}

extension ChangePasswordEnterNewView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        endEditing(true)
        guard presenter.isPasswordChangeAllowed(firstPassword: firstPasswordInput.text,
                                                secondPassword: secondPasswordInput.text,
                                                isAgreeChangePasswordChecked:
                                                    agreeChangePasswordCheck.isChecked)
        else {
            Logger.log(.err, "Change password button should be deactivated")
            return
        }
        delegate?.didEnterNewPassword(firstPasswordInput.text)
    }
}

extension ChangePasswordEnterNewView: TextInputViewDelegate {

    func onTextChange(textInputView: TextInputView, text: String) {
        let firstPassword = textInputView == firstPasswordInput ? text : firstPasswordInput.text
        let secondPassword = textInputView == secondPasswordInput ? text : secondPasswordInput.text
        presenter.onInputPasswordStateChanged(firstPassword: firstPassword,
            secondPassword: secondPassword,
            isAgreeChangePasswordChecked: agreeChangePasswordCheck.isChecked)
    }
}

extension ChangePasswordEnterNewView: UITestablePage {

    typealias UIElementType = UIElements.Pages.ChangePasswordEnterNew

    func makeViewTestable() {
        self.makeViewTestable(self, using: .root)
        self.makeViewTestable(firstPasswordInput, using: .firstTextInput)
        self.makeViewTestable(secondPasswordInput, using: .secondTextInput)
        self.makeViewTestable(confirmButton, using: .confirmButton)
        self.makeViewTestable(agreeChangePasswordCheck, using: .agreeChangePasswordCheck)
    }
}

extension ChangePasswordEnterNewView: CheckViewDelegate {
    func onCheckChanged(checked: Bool) {
        presenter.onInputPasswordStateChanged(firstPassword: firstPasswordInput.text,
            secondPassword: secondPasswordInput.text,
            isAgreeChangePasswordChecked: checked)
    }
}

extension ChangePasswordEnterNewView: ChangePasswordNewViewPresenterDelegate {
    func updateUi(state: ChangePasswordState) {
        switch state {
        case .inputPassword:
            confirmButton.isEnabled = false
        case .passwordMatch:
            confirmButton.isEnabled = false
            agreeChangePasswordCheck.animate(direction: .topToBottom, duration: .short)
        case .passwordDoesNotMatch:
            confirmButton.isEnabled = false
            secondPasswordInput.setError(L10n.ChangePasswordEnterNewView.s6)
        case .confirmPassword:
            confirmButton.isEnabled = true
        }
    }
}
