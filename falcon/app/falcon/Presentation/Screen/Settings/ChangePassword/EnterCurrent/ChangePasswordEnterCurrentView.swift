//
//  ChangePasswordEnterCurrentView.swift
//  falcon
//
//  Created by Manu Herrera on 27/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ChangePasswordEnterCurrentViewDelegate: class {
    func didConfirm(_ password: String)
    func didTapForgotPasswordButton()
}

final class ChangePasswordEnterCurrentView: UIView {

    private var contentVerticalStack: UIStackView!
    private var titleAndDescriptionView: TitleAndDescriptionView!
    private var passwordInput: TextInputView!
    private var buttonsVerticalStack: UIStackView!
    private var forgotPasswordButton: LinkButtonView!
    private var confirmButton: ButtonView!

    private weak var delegate: ChangePasswordEnterCurrentViewDelegate?

    private var bottomMarginConstraint: NSLayoutConstraint!

    init(delegate: ChangePasswordEnterCurrentViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpButtonsStackView()
        setUpContentStackView()

        makeViewTestable()
    }

    private func setUpContentStackView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsVerticalStack.topAnchor),
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
        setUpTextView()
    }

    private func setUpTItleAndDescriptionView() {
        titleAndDescriptionView = TitleAndDescriptionView()
        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        titleAndDescriptionView.titleText = L10n.ChangePasswordEnterCurrentView.s1
        titleAndDescriptionView.descriptionText = L10n.ChangePasswordEnterCurrentView.s7
            .attributedForDescription()
        titleAndDescriptionView.animate()
        contentVerticalStack.addArrangedSubview(titleAndDescriptionView)
    }

    private func setUpTextView() {
        passwordInput = TextInputView()
        passwordInput.translatesAutoresizingMaskIntoConstraints = false
        passwordInput.isPassword = true
        passwordInput.topLabel = L10n.ChangePasswordEnterCurrentView.s2
        passwordInput.bottomLabel = L10n.ChangePasswordEnterCurrentView.s3
        passwordInput.delegate = self
        contentVerticalStack.addArrangedSubview(passwordInput)
    }

    private func setUpButtonsStackView() {
        buttonsVerticalStack = UIStackView()
        buttonsVerticalStack.axis = .vertical
        buttonsVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsVerticalStack.spacing = 0
        bottomMarginConstraint = NSLayoutConstraint(
            item: buttonsVerticalStack!,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: layoutMarginsGuide,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )

        addSubview(buttonsVerticalStack)
        NSLayoutConstraint.activate([
            bottomMarginConstraint,
            buttonsVerticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            buttonsVerticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])

        setUpForgotPasswordButton()
        setUpConfirmButton()
    }

    private func setUpConfirmButton() {
        confirmButton = ButtonView()
        confirmButton.delegate = self
        confirmButton.buttonText = L10n.ChangePasswordEnterCurrentView.s4
        confirmButton.isEnabled = false

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsVerticalStack.addArrangedSubview(confirmButton)
    }

    private func setUpForgotPasswordButton() {
        forgotPasswordButton = LinkButtonView()
        forgotPasswordButton.delegate = self
        forgotPasswordButton.buttonText = L10n.ChangePasswordEnterCurrentView.s5
        forgotPasswordButton.isEnabled = true

        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsVerticalStack.addArrangedSubview(forgotPasswordButton)
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

    func setInvalidPassword() {
        passwordInput.setError(L10n.ChangePasswordEnterCurrentView.s6)
    }

    func makePasswordInputFirstResponder() {
        _ = passwordInput.becomeFirstResponder()
    }

}

extension ChangePasswordEnterCurrentView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        endEditing(true)

        delegate?.didConfirm(passwordInput.text)
    }

}

extension ChangePasswordEnterCurrentView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        delegate?.didTapForgotPasswordButton()
    }

}

extension ChangePasswordEnterCurrentView: TextInputViewDelegate {
    func onTextChange(textInputView: TextInputView, text: String) {
        confirmButton.isEnabled = text.count >= 8
    }

}

extension ChangePasswordEnterCurrentView: UITestablePage {

    typealias UIElementType = UIElements.Pages.ChangePasswordEnterCurrent

    func makeViewTestable() {
        self.makeViewTestable(self, using: .root)
        self.makeViewTestable(confirmButton, using: .confirmButton)
        self.makeViewTestable(forgotPasswordButton, using: .forgotPasswordButton)
        self.makeViewTestable(passwordInput, using: .textInput)
    }

}
