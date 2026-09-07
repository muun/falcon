//
//  SecurityCardTextField.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardTextFieldDelegate: AnyObject {
    func securityCardTextFieldDidChange(_ field: SecurityCardTextField)
    func securityCardTextFieldDidTap(_ field: SecurityCardTextField)
    /// Return `false` to signal the field handled the return key itself
    /// (e.g. by moving focus to another field).
    func securityCardTextFieldShouldReturn(_ field: SecurityCardTextField) -> Bool
}

extension SecurityCardTextFieldDelegate {
    func securityCardTextFieldDidChange(_ field: SecurityCardTextField) {}
    func securityCardTextFieldDidTap(_ field: SecurityCardTextField) {}
    func securityCardTextFieldShouldReturn(_ field: SecurityCardTextField) -> Bool { true }
}

/// Rounded floating-label text field matching the security cards prototype style.
/// Supports a tappable (non-editable) mode for pickers like Country/Region.
final class SecurityCardTextField: UIView {

    weak var delegate: SecurityCardTextFieldDelegate?

    private let containerView = UIView()
    private let textField = UITextField()
    private let floatingLabel = UILabel()
    private let errorLabel = UILabel()

    private var labelTopConstraint: NSLayoutConstraint!

    var text: String {
        get { textField.text ?? "" }
        set {
            textField.text = newValue
            updateFloatingLabel(animated: false)
        }
    }

    var errorText: String? {
        didSet { applyErrorState() }
    }

    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }

    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }

    /// Accessory shown above the keyboard while this field edits (e.g. a prev/next toolbar).
    var keyboardAccessoryView: UIView? {
        get { textField.inputAccessoryView }
        set { textField.inputAccessoryView = newValue }
    }

    override var isFirstResponder: Bool { textField.isFirstResponder }

    @discardableResult
    override func becomeFirstResponder() -> Bool { textField.becomeFirstResponder() }

    @discardableResult
    override func resignFirstResponder() -> Bool { textField.resignFirstResponder() }

    // MARK: - Init

    init(label: String, tappable: Bool = false) {
        super.init(frame: .zero)
        floatingLabel.text = label
        if tappable {
            setupTappableField()
        } else {
            setupEditableField()
        }
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Field mode

    private func setupEditableField() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    private func setupTappableField() {
        // Block taps on the inner field so the parent tap gesture handles them and the
        // keyboard never opens for picker-style rows (e.g. Country).
        textField.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Layout

    private func setupLayout() {
        setupContainer()
        setupTextField()
        setupFloatingLabel()
        setupErrorLabel()
        activateConstraints()
    }

    private func setupContainer() {
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = MuunTheme.Color.Border.primary.cgColor
        containerView.backgroundColor = MuunTheme.Component.TextField.background
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
    }

    private func setupTextField() {
        textField.borderStyle = .none
        textField.font = MuunTheme.Font.Body.md
        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textField)
    }

    private func setupFloatingLabel() {
        // Expanded state mirrors the prototype's 18pt label.
        floatingLabel.font = MuunTheme.Font.Body.lg
        floatingLabel.textColor = MuunTheme.Color.Text.bodySecondary
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(floatingLabel)
    }

    private func setupErrorLabel() {
        errorLabel.font = MuunTheme.Font.Body.xs
        errorLabel.textColor = MuunTheme.Color.Text.error
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
    }

    private func activateConstraints() {
        let containerHeight: CGFloat = 58
        let fieldHeight: CGFloat = 22
        let fieldBottomInset: CGFloat = 10

        labelTopConstraint = floatingLabel.topAnchor.constraint(
            equalTo: containerView.topAnchor,
            constant: MuunTheme.Spacing.lg
        )

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),

            textField.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            textField.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -MuunTheme.Spacing.sm
            ),
            textField.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -fieldBottomInset
            ),
            textField.heightAnchor.constraint(equalToConstant: fieldHeight),

            labelTopConstraint,
            floatingLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            floatingLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -MuunTheme.Spacing.sm
            ),

            errorLabel.topAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: MuunTheme.Spacing.xs2
            ),
            errorLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Floating label animation

    private func updateFloatingLabel(animated: Bool) {
        let collapsedTop: CGFloat = 10
        let animationDuration: TimeInterval = 0.15
        let hasContent = !text.isEmpty
        let targetTop: CGFloat = hasContent ? collapsedTop : MuunTheme.Spacing.lg
        // Prototype scales label 1 → 0.75 on focus, i.e. Body.lg (18) → Body.sm (14).
        let targetFont: UIFont = hasContent ? MuunTheme.Font.Body.sm : MuunTheme.Font.Body.lg

        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.labelTopConstraint.constant = targetTop
                self.floatingLabel.font = targetFont
                self.layoutIfNeeded()
            }
        } else {
            labelTopConstraint.constant = targetTop
            floatingLabel.font = targetFont
        }
    }

    private func applyErrorState() {
        let hasError = errorText != nil
        containerView.layer.borderColor = hasError
            ? MuunTheme.Color.Text.error.cgColor
            : MuunTheme.Color.Border.primary.cgColor
        floatingLabel.textColor = hasError
            ? MuunTheme.Color.Text.error
            : MuunTheme.Color.Text.bodySecondary
        errorLabel.text = errorText
        errorLabel.isHidden = !hasError
    }

    // MARK: - Actions

    @objc private func textDidChange() {
        updateFloatingLabel(animated: true)
        delegate?.securityCardTextFieldDidChange(self)
    }

    @objc private func handleTap() {
        delegate?.securityCardTextFieldDidTap(self)
    }
}

// MARK: - UITextFieldDelegate

extension SecurityCardTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorText = nil
        updateFloatingLabel(animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateFloatingLabel(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.securityCardTextFieldShouldReturn(self) ?? true
    }
}
