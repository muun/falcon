//
//  MarketplacePresenter.swift
//  falcon
//
//  Created by Federico Jordán on 15/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

protocol MarketplacePresenterDelegate: BasePresenterDelegate {
    func update(providers: [SecurityCardProvider])
}

final class MarketplacePresenter<Delegate: MarketplacePresenterDelegate>: BasePresenter<Delegate> {

    private let getSecurityCardsMarketplaceAction: GetSecurityCardsMarketplaceAction = resolve()
    private let cardPriceFormatter: CardPriceFormatter = resolve()
    private let getSecurityCardCountryAction: GetSecurityCardCountryAction = resolve()
    private let setSecurityCardCountryAction: SetSecurityCardCountryAction = resolve()

    var selectedCountryCode: String { getSecurityCardCountryAction.run().code }
    var selectedCountryFlag: String { getSecurityCardCountryAction.run().flag }

    func loadData() {
        subscribeTo(getSecurityCardsMarketplaceAction.run(), onSuccess: { [weak self] providers in
            self?.delegate.update(providers: providers)
        })
    }

    /// Records the country selected in the marketplace so downstream screens
    /// (e.g. shipping) can default to it.
    func set(selectedCountry country: Country) {
        setSecurityCardCountryAction.run(country)
    }

}

// MARK: - CardPriceFormatter

extension MarketplacePresenter: CardPriceFormatter {

    func formattedPrice(for provider: SecurityCardProvider, showBTC: Bool) -> FormattedCardPrice? {
        cardPriceFormatter.formattedPrice(for: provider, showBTC: showBTC)
    }

    func format(_ amount: Decimal, currencyCode: String, showBTC: Bool) -> String? {
        cardPriceFormatter.format(amount, currencyCode: currencyCode, showBTC: showBTC)
    }
}
