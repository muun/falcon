//
//  ShippingPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

struct ShippingViewModel {
    let providerName: String
    let providerColor: UIColor
    let providerUrl: URL?
    let country: String
}

protocol ShippingPresenterDelegate: BasePresenterDelegate {
    func update(viewModel: ShippingViewModel)
    func displayFormErrors(_ errors: [ShippingFormField: String])
    func didValidateForm(provider: SecurityCardProvider, values: ShippingFormValues)
}

final class ShippingPresenter<Delegate: ShippingPresenterDelegate>: BasePresenter<Delegate> {

    private let provider: SecurityCardProvider
    private let getSecurityCardCountryAction: GetSecurityCardCountryAction = resolve()
    private let setSecurityCardCountryAction: SetSecurityCardCountryAction = resolve()

    var providerURL: URL? { provider.siteUrl }
    var selectedCountryCode: String { getSecurityCardCountryAction.run().code }

    init(delegate: Delegate, provider: SecurityCardProvider) {
        self.provider = provider
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()
        delegate.update(viewModel: buildViewModel(country: getSecurityCardCountryAction.run()))
    }

    /// Updates the shipping country from the picker, recording it as the shared
    /// selection so upstream screens (e.g. the marketplace) stay in sync.
    func update(country: Country) {
        setSecurityCardCountryAction.run(country)
        delegate.update(viewModel: buildViewModel(country: country))
    }

    /// Validates the submitted form. On success the view advances to the order
    /// summary; otherwise per-field errors are pushed back to the view.
    func submit(_ values: ShippingFormValues) {
        let errors = validationErrors(for: values)
        guard errors.isEmpty else {
            delegate.displayFormErrors(errors)
            return
        }
        delegate.didValidateForm(provider: provider, values: values)
    }

    private func validationErrors(for values: ShippingFormValues) -> [ShippingFormField: String] {
        var errors: [ShippingFormField: String] = [:]

        let requiredFields: [(ShippingFormField, String, String)] = [
            (.fullName, values.fullName, L10n.ShippingFormView.fullNameRequired),
            (.email, values.email, L10n.ShippingFormView.emailRequired),
            (
                .shippingAddress,
                values.shippingAddress,
                L10n.ShippingFormView.shippingAddressRequired
            ),
            (.city, values.city, L10n.ShippingFormView.cityRequired),
            (.state, values.state, L10n.ShippingFormView.stateRequired),
            (.zipCode, values.zipCode, L10n.ShippingFormView.zipCodeRequired)
        ]

        for (key, value, message) in requiredFields where value.isEmpty {
            errors[key] = message
        }

        if !values.email.isEmpty && !EmailValidator.isValid(values.email) {
            errors[.email] = L10n.ShippingFormView.emailInvalid
        }

        return errors
    }

    private func buildViewModel(country: Country) -> ShippingViewModel {
        ShippingViewModel(
            providerName: provider.name,
            providerColor: UIColor(hex: provider.colorHex),
            providerUrl: provider.siteUrl,
            country: "\(country.flag) \(country.name)"
        )
    }
}
