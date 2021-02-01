//
//  ChangePasswordEnterRecoveryCodeView.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

protocol ChangePasswordEnterRecoveryCodeViewDelegate: class {
    func didConfirmRecoveryCode(_ code: String)
}

final class ChangePasswordEnterRecoveryCodeView: UIView {

    private var contentVerticalStack: UIStackView!
    private var titleAndDescriptionView: TitleAndDescriptionView!
    private var recoveryCodeView: RecoveryView!
    private var errorLabel: UILabel!
    private var bottomMarginConstraint: NSLayoutConstraint!

    private var continueButton: ButtonView!
    private var recoveryCode: RecoveryCode?

    private weak var delegate: ChangePasswordEnterRecoveryCodeViewDelegate?

    init(delegate: ChangePasswordEnterRecoveryCodeViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpStackView()
        setUpContinueButton()

        makeViewTestable()
    }

    private func setUpContinueButton() {
        continueButton = ButtonView()
        continueButton.buttonText = L10n.ChangePasswordEnterRecoveryCodeView.s1
        continueButton.isEnabled = false
        continueButton.delegate = self
        continueButton.alpha = 0

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(continueButton)

        bottomMarginConstraint = NSLayoutConstraint(
            item: continueButton!,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: layoutMarginsGuide,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        NSLayoutConstraint.activate([
            bottomMarginConstraint,
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    private func setUpStackView() {
        contentVerticalStack = UIStackView()
        contentVerticalStack.axis = .vertical
        contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.spacing = 32

        addSubview(contentVerticalStack)
        NSLayoutConstraint.activate([
            contentVerticalStack.topAnchor.constraint(equalTo: topAnchor),
            contentVerticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            contentVerticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])

        setUpTitleAndDescriptionView()
        setUpRecoveryView()
        setUpErrorLabel()
    }

    private func setUpTitleAndDescriptionView() {
        titleAndDescriptionView = TitleAndDescriptionView()

        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        titleAndDescriptionView.titleText = L10n.ChangePasswordEnterRecoveryCodeView.s2
        titleAndDescriptionView.descriptionText = nil
        contentVerticalStack.addArrangedSubview(titleAndDescriptionView)
    }

    private func setUpRecoveryView() {
        recoveryCodeView = RecoveryView()
        recoveryCodeView.delegate = self
        recoveryCodeView.style = .editable
        recoveryCodeView.isLoading = false
        recoveryCodeView.alpha = 0

        recoveryCodeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recoveryCodeView.heightAnchor.constraint(equalToConstant: 124)
        ])
        contentVerticalStack.addArrangedSubview(recoveryCodeView)
        contentVerticalStack.setCustomSpacing(8, after: recoveryCodeView)
    }

    private func setUpErrorLabel() {
        errorLabel = UILabel()
        errorLabel.text = L10n.ChangePasswordEnterRecoveryCodeView.s3
        errorLabel.numberOfLines = 0
        errorLabel.style = .error
        errorLabel.textAlignment = .left
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        contentVerticalStack.addArrangedSubview(errorLabel)
    }

    // MARK: - View Controller actions -

    func wrongCode() {
        continueButton.isEnabled = false
        errorLabel.isHidden = false
    }

    func animateBottomMarginTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.bottomMarginConstraint.constant = -height

            self.layoutIfNeeded()
        }
    }

    func setButtonLoading(_ isLoading: Bool) {
        continueButton.isLoading = isLoading
    }

    func animate() {
        titleAndDescriptionView.animate()
        recoveryCodeView.animate(direction: .topToBottom, duration: .short)
        continueButton.animate(direction: .bottomToTop, duration: .short)
    }

}

extension ChangePasswordEnterRecoveryCodeView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        guard let code = recoveryCode?.description else {
            return
        }
        delegate?.didConfirmRecoveryCode(code)
    }

}

extension ChangePasswordEnterRecoveryCodeView: RecoveryViewDelegate {

    func recoveryViewDidChange(_ recoveryView: RecoveryView, code: RecoveryCode?) {

        guard let code = code else {
            continueButton.isEnabled = false
            errorLabel.isHidden = true
            return
        }

        self.recoveryCode = code
        continueButton.isEnabled = true
    }

}

extension ChangePasswordEnterRecoveryCodeView: UITestablePage {

    typealias UIElementType = UIElements.Pages.ChangePasswordEnterRecoveryCode

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(recoveryCodeView, using: .codeView)
        makeViewTestable(errorLabel, using: .errorLabel)
        makeViewTestable(continueButton, using: .continueButton)
    }

}
