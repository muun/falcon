//
//  SignInWithRCView.swift
//  falcon
//
//  Created by Manu Herrera on 09/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

protocol SignInWithRCViewDelegate: AnyObject {
    func didConfirmRecoveryCode(_ code: String)
    func moreInfoTouched()
    func tapOnIncorrectRecoveryCodeLabel()
}

final class SignInWithRCView: UIView {

    private var scrollView: UIScrollView!
    private var contentVerticalStack: UIStackView!
    private var titleAndDescriptionView: TitleAndDescriptionView!
    private var recoveryCodeView: RecoveryView!
    private var errorLabel: UILabel!
    private var bottomMarginConstraint: NSLayoutConstraint!

    private var continueButton: ButtonView!
    private var recoveryCode: RecoveryCode?

    private weak var delegate: SignInWithRCViewDelegate?

    init(delegate: SignInWithRCViewDelegate?) {
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
        continueButton.buttonText = L10n.SignInWithRCView.s1
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
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor)
        ])
    }

    private func setUpStackView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])

        contentVerticalStack = UIStackView()
        contentVerticalStack.axis = .vertical
        contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.spacing = 32
        contentVerticalStack.distribution = .equalSpacing
        contentVerticalStack.alignment = .fill

        scrollView.addSubview(contentVerticalStack)
        NSLayoutConstraint.activate([
            contentVerticalStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentVerticalStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentVerticalStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentVerticalStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentVerticalStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        setUpTitleAndDescriptionView()
        setUpRecoveryView()
        setUpErrorLabel()
    }

    private func setUpTitleAndDescriptionView() {
        titleAndDescriptionView = TitleAndDescriptionView()

        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        titleAndDescriptionView.titleText = L10n.SignInWithRCView.s2
        let desc = L10n.SignInWithRCView.s3
        titleAndDescriptionView.descriptionText = desc.attributedForDescription()
            .set(underline: desc, color: Asset.Colors.muunBlue.color)
        titleAndDescriptionView.delegate = self
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
        contentVerticalStack.setCustomSpacing(.sideMargin, after: recoveryCodeView)
    }

    private func setUpErrorLabel() {
        errorLabel = UILabel()
        errorLabel.numberOfLines = 0
        errorLabel.style = .error
        errorLabel.textAlignment = .left
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        contentVerticalStack.addArrangedSubview(errorLabel)
    }

    @objc fileprivate func tapOnErrorLabel() {
        delegate?.tapOnIncorrectRecoveryCodeLabel()
    }

    // MARK: - View Controller actions -

    func wrongCode() {
        errorLabel.text = L10n.SignInWithRCView.s4
        continueButton.isEnabled = false
        errorLabel.isHidden = false
    }

    func wrongRecoveryCodeVersion() {
        let actionText = L10n.SignInWithRCView.s5
        errorLabel.attributedText = L10n.SignInWithRCView.s6
            .attributedForDescription()
            .set(underline: actionText, color: Asset.Colors.muunBlue.color)
        continueButton.isEnabled = false
        errorLabel.isHidden = false
        errorLabel.isUserInteractionEnabled = true

        errorLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .tapOnErrorLabel))
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

extension SignInWithRCView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        guard let code = recoveryCode?.description else {
            return
        }
        delegate?.didConfirmRecoveryCode(code)
    }

}

extension SignInWithRCView: TitleAndDescriptionViewDelegate {
    func descriptionTouched() {
        delegate?.moreInfoTouched()
    }
}

extension SignInWithRCView: RecoveryViewDelegate {

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

extension SignInWithRCView: UITestablePage {

    typealias UIElementType = UIElements.Pages.SignInWithRCPage

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(recoveryCodeView, using: .codeView)
        makeViewTestable(errorLabel, using: .errorLabel)
        makeViewTestable(continueButton, using: .continueButton)
    }

}

fileprivate extension Selector {
    static let tapOnErrorLabel = #selector(SignInWithRCView.tapOnErrorLabel)
}
