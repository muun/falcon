//
//  DefaultCardPriceFormatter.swift
//  falcon
//
//  Created by Federico Jordán on 02/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

struct FormattedCardPrice {
    let price: String
    let shipping: String
}

protocol CardPriceFormatter: AnyObject {
    func formattedPrice(for provider: SecurityCardProvider, showBTC: Bool) -> FormattedCardPrice?
    /// Formats an arbitrary amount in the given currency. When `showBTC` is true it
    /// converts using the current exchange-rate window, returning nil if it's unavailable.
    func format(_ amount: Decimal, currencyCode: String, showBTC: Bool) -> String?
}

final class DefaultCardPriceFormatter: CardPriceFormatter {

    private let exchangeRateRepository: ExchangeRateWindowRepository

    init(exchangeRateRepository: ExchangeRateWindowRepository) {
        self.exchangeRateRepository = exchangeRateRepository
    }

    func formattedPrice(
        for provider: SecurityCardProvider,
        showBTC: Bool
    ) -> FormattedCardPrice? {
        let code = provider.currencyCode
        guard
            let price = format(Decimal(provider.price), currencyCode: code, showBTC: showBTC),
            let shipping = format(
                Decimal(provider.shippingCost),
                currencyCode: code,
                showBTC: showBTC
            )
        else {
            return nil
        }
        return FormattedCardPrice(price: price, shipping: shipping)
    }

    func format(_ amount: Decimal, currencyCode: String, showBTC: Bool) -> String? {
        if showBTC {
            guard let btc = btcAmount(amount, currencyCode: currencyCode) else { return nil }
            return MonetaryAmount(amount: btc, currency: "BTC").toAmountPlusCode()
        }
        return MonetaryAmount(amount: amount, currency: currencyCode).toAmountPlusCode()
    }

    /// Converts a fiat amount to BTC using the current exchange-rate window.
    private func btcAmount(_ amount: Decimal, currencyCode: String) -> Decimal? {
        guard let window = exchangeRateRepository.getExchangeRateWindow() else {
            return nil
        }
        let rate: Decimal
        do {
            rate = try window.rate(for: currencyCode)
        } catch {
            return nil
        }
        guard rate > 0 else {
            return nil
        }
        return amount / rate
    }
}
