//
//  ShippingFormView.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol ShippingFormViewDelegate: AnyObject {
    func shippingFormViewDidTapCountry(_ view: ShippingFormView)
}

struct ShippingFormViewModel {
    let countryName: String
}

struct ShippingFormValues {
    let fullName: String
    let email: String
    let shippingAddress: String
    let country: String
    let city: String
    let state: String
    let zipCode: String
}

/// Editable fields that can carry a validation error. The country row is excluded:
/// it's a non-editable picker that's always pre-filled.
enum ShippingFormField {
    case fullName
    case email
    case shippingAddress
    case city
    case state
    case zipCode
}

final class ShippingFormView: UIView {

    weak var delegate: ShippingFormViewDelegate?

    private let fullNameField = SecurityCardTextField(label: L10n.ShippingFormView.fullName)
    private let emailField = SecurityCardTextField(label: L10n.ShippingFormView.email)
    private let shippingAddressField = SecurityCardTextField(
        label: L10n.ShippingFormView.shippingAddress
    )
    private let countryField = SecurityCardTextField(
        label: L10n.ShippingFormView.countryRegion,
        tappable: true
    )
    private let cityField = SecurityCardTextField(label: L10n.ShippingFormView.city)
    private let stateField = SecurityCardTextField(label: L10n.ShippingFormView.state)
    private let zipCodeField = SecurityCardTextField(label: L10n.ShippingFormView.zipCode)

    /// Single source of the editable fields, in form order. Add new fields here so error
    /// display, delegate wiring and keyboard navigation pick them up automatically. The
    /// country row is excluded: it's a picker that opens a modal instead of the keyboard.
    private lazy var editableFields: [(key: ShippingFormField, field: SecurityCardTextField)] = [
        (.fullName, fullNameField),
        (.email, emailField),
        (.shippingAddress, shippingAddressField),
        (.city, cityField),
        (.state, stateField),
        (.zipCode, zipCodeField)
    ]

    private var orderedEditableFields: [SecurityCardTextField] {
        editableFields.map(\.field)
    }

    private var allFields: [SecurityCardTextField] {
        orderedEditableFields + [countryField]
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureFields()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Public API

    func configure(viewModel: ShippingFormViewModel) {
        countryField.text = viewModel.countryName
    }

    func formValues() -> ShippingFormValues {
        ShippingFormValues(
            fullName: trimmed(fullNameField),
            email: trimmed(emailField),
            shippingAddress: trimmed(shippingAddressField),
            country: trimmed(countryField),
            city: trimmed(cityField),
            state: trimmed(stateField),
            zipCode: trimmed(zipCodeField)
        )
    }

    /// Shows the given per-field errors and clears any field not present in the map.
    func showErrors(_ errors: [ShippingFormField: String]) {
        for (key, field) in editableFields {
            field.errorText = errors[key]
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = MuunTheme.Spacing.xl2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let countryRow = makeRow(countryField, cityField)
        let stateRow = makeRow(stateField, zipCodeField)

        [fullNameField, emailField, shippingAddressField, countryRow, stateRow].forEach {
            stack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func makeRow(_ left: UIView, _ right: UIView) -> UIView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = MuunTheme.Spacing.xl
        return row
    }

    private func configureFields() {
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no

        fullNameField.autocapitalizationType = .words
        shippingAddressField.autocapitalizationType = .words
        cityField.autocapitalizationType = .words
        stateField.autocapitalizationType = .words
        zipCodeField.autocapitalizationType = .allCharacters
        zipCodeField.autocorrectionType = .no

        for field in allFields {
            field.delegate = self
        }

        configureKeyboardNavigation()
    }

    // MARK: - Keyboard navigation

    /// Wires the return key and a prev/next/done toolbar so the user can move between
    /// editable fields without dismissing the keyboard.
    private func configureKeyboardNavigation() {
        let fields = orderedEditableFields
        for (index, field) in fields.enumerated() {
            let isLast = index == fields.count - 1
            field.returnKeyType = isLast ? .done : .next
            field.keyboardAccessoryView = makeNavigationToolbar(for: index)
        }
    }

    private func makeNavigationToolbar(for index: Int) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let previous = UIBarButtonItem(
            image: UIImage(systemName: "chevron.up"),
            primaryAction: UIAction { [weak self] _ in self?.focusField(at: index - 1) }
        )
        previous.isEnabled = index > 0
        previous.accessibilityLabel = L10n.KeyboardToolbar.previous

        let next = UIBarButtonItem(
            image: UIImage(systemName: "chevron.down"),
            primaryAction: UIAction { [weak self] _ in self?.focusField(at: index + 1) }
        )
        next.isEnabled = index < orderedEditableFields.count - 1
        next.accessibilityLabel = L10n.KeyboardToolbar.next

        let done = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in self?.endEditing(true) }
        )

        toolbar.items = [
            previous,
            next,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            done
        ]
        return toolbar
    }

    private func focusField(at index: Int) {
        guard orderedEditableFields.indices.contains(index) else { return }
        orderedEditableFields[index].becomeFirstResponder()
    }

    // MARK: - Helpers

    private func trimmed(_ field: SecurityCardTextField) -> String {
        field.text.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - SecurityCardTextFieldDelegate

extension ShippingFormView: SecurityCardTextFieldDelegate {

    func securityCardTextFieldDidTap(_ field: SecurityCardTextField) {
        guard field === countryField else { return }
        delegate?.shippingFormViewDidTapCountry(self)
    }

    func securityCardTextFieldShouldReturn(_ field: SecurityCardTextField) -> Bool {
        guard let index = orderedEditableFields.firstIndex(where: { $0 === field }) else {
            return true
        }
        let nextIndex = index + 1
        if orderedEditableFields.indices.contains(nextIndex) {
            focusField(at: nextIndex)
        } else {
            endEditing(true)
        }
        return false
    }
}
