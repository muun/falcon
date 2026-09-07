//
//  PayWithMuunPresenter.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

protocol PayWithMuunPresenterDelegate: BasePresenterDelegate {
    func onLoad(_ viewModel: PayWithMuunViewModel)
    func onChange(breakdown: PayWithMuunViewModel.BreakdownViewModel)
}

final class PayWithMuunPresenter<Delegate: PayWithMuunPresenterDelegate>: BasePresenter<Delegate> {

    private let provider: SecurityCardProvider
    private let orderTotal: Decimal
    private let priceCurrencyToggle: CardPriceCurrencyToggle

    init(delegate: Delegate, provider: SecurityCardProvider, orderTotal: Decimal) {
        self.provider = provider
        self.orderTotal = orderTotal
        self.priceCurrencyToggle = CardPriceCurrencyToggle(currencyCode: provider.currencyCode)
        super.init(delegate: delegate)
    }

    func load() {
        delegate.onLoad(
            PayWithMuunViewModel(
                providerName: provider.name,
                breakdown: buildBreakdown()
            )
        )
    }

    func didTapCurrencyToggle() {
        guard priceCurrencyToggle.toggle() else { return }
        delegate.onChange(breakdown: buildBreakdown())
    }

    // MARK: - Breakdown

    private func buildBreakdown() -> PayWithMuunViewModel.BreakdownViewModel {
        let networkFee = orderTotal / 10 // TODO: use the real network fee from the payment flow.
        return .init(
            amount: priceCurrencyToggle.format(orderTotal),
            networkFee: priceCurrencyToggle.format(networkFee),
            total: priceCurrencyToggle.format(orderTotal + networkFee)
        )
    }
}
