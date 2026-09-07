//
//  OrderSummaryPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol OrderSummaryPresenterDelegate: BasePresenterDelegate {
    func onLoad(_ viewModel: OrderSummaryViewModel)
    func onChange(
        selectedSpeed: DeliveryOption.Speed,
        breakdown: OrderSummaryViewModel.BreakdownViewModel
    )
}

final class OrderSummaryPresenter<Delegate: OrderSummaryPresenterDelegate>: BasePresenter<Delegate> {

    let provider: SecurityCardProvider
    private let shippingValues: ShippingFormValues
    private let priceCurrencyToggle: CardPriceCurrencyToggle
    private var selectedDeliverySpeed: DeliveryOption.Speed

    // TODO: derive options (and surcharges) from provider + country.
    private let deliveryOptions: [DeliveryOption] = [
        DeliveryOption(speed: .standard, surcharge: 0),
        DeliveryOption(speed: .express, surcharge: 15)
    ]

    init(
        delegate: Delegate,
        provider: SecurityCardProvider,
        shippingValues: ShippingFormValues
    ) {
        self.provider = provider
        self.shippingValues = shippingValues
        self.priceCurrencyToggle = CardPriceCurrencyToggle(currencyCode: provider.currencyCode)
        self.selectedDeliverySpeed = deliveryOptions.first?.speed ?? .standard
        super.init(delegate: delegate)
    }

    /// Static screen: build the view model once, on `viewDidLoad`.
    func load() {
        delegate.onLoad(buildViewModel())
    }

    func didChangeDeliverySpeed(_ speed: DeliveryOption.Speed) {
        selectedDeliverySpeed = speed
        delegate.onChange(selectedSpeed: speed, breakdown: buildBreakdown())
    }

    func didTapCurrencyToggle() {
        guard priceCurrencyToggle.toggle() else { return }
        delegate.onChange(selectedSpeed: selectedDeliverySpeed, breakdown: buildBreakdown())
    }

    var providerURL: URL? { provider.siteUrl }

    // MARK: - Private

    private func buildViewModel() -> OrderSummaryViewModel {
        return OrderSummaryViewModel(
            providerColor: providerColor,
            providerUrl: provider.siteUrl,
            securityCardImageName: provider.cards.first?.imageName ?? "",
            shippingDetails: buildShippingDetails(),
            breakdown: buildBreakdown(),
            options: buildOptions()
        )
    }

    private var providerColor: UIColor {
        UIColor(hex: provider.colorHex)
    }

    private func buildShippingDetails() -> OrderSummaryViewModel.ShippingDetailsViewModel {
        return OrderSummaryViewModel.ShippingDetailsViewModel(
            name: shippingValues.fullName,
            email: shippingValues.email,
            address: formattedAddress(from: shippingValues)
        )
    }

    /// Mirrors the prototype: "Mont des Arts 1, 1000 Bruxelles, Belgium" — no state,
    /// and the country without its flag (`shippingValues.country` is "🇧🇪 Belgium").
    private func formattedAddress(from values: ShippingFormValues) -> String {
        let country = values.country
            .split(separator: " ")
            .dropFirst()
            .joined(separator: " ")
        let countryName = country.isEmpty ? values.country : country
        return "\(values.shippingAddress), \(values.zipCode) \(values.city), \(countryName)"
    }

    // MARK: - Delivery options

    private func buildOptions() -> [DeliveryMethodOptionViewModel] {
        deliveryOptions.map { option in
            DeliveryMethodOptionViewModel(
                speed: option.speed,
                surcharge: option.surcharge,
                currencyCode: provider.currencyCode,
                isSelected: option.speed == selectedDeliverySpeed,
                providerColor: providerColor
            )
        }
    }

    var orderTotal: Decimal {
        Decimal(provider.price) + selectedSurcharge
    }

    private var selectedSurcharge: Decimal {
        let selectedDeliveryOption = deliveryOptions.first { $0.speed == selectedDeliverySpeed }
        return selectedDeliveryOption?.surcharge ?? 0
    }

    // MARK: - Breakdown

    // TODO: replace mocked amounts with real calculations from provider pricing.
    private func buildBreakdown() -> OrderSummaryViewModel.BreakdownViewModel {
        let price = Decimal(provider.price)
        let shippingAndTaxes = selectedSurcharge // taxes are 0 while mocked
        return OrderSummaryViewModel.BreakdownViewModel(
            price: priceCurrencyToggle.format(price),
            shippingAndTaxes: priceCurrencyToggle.format(shippingAndTaxes),
            total: priceCurrencyToggle.format(price + shippingAndTaxes)
        )
    }
}
