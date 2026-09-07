//
//  CardPriceCurrencyToggle.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

/// Fiat <-> BTC display toggle for card prices, shared by the order-summary and pay-with-Muun
/// presenters. It owns the invariant that we only switch to BTC when the rate window can
/// convert the currency; otherwise the formatter falls back to fiat and the toggle state would
/// drift from what's shown.
final class CardPriceCurrencyToggle: Resolver {

    private let currencyCode: String
    private let formatter: CardPriceFormatter
    private(set) var showingBTC = false

    init(currencyCode: String, formatter: CardPriceFormatter = resolve()) {
        self.currencyCode = currencyCode
        self.formatter = formatter
    }

    /// Flips fiat <-> BTC, returning whether the state changed (it won't switch to BTC when
    /// no rate is available).
    func toggle() -> Bool {
        if !showingBTC, !canShowBTC { return false }
        showingBTC.toggle()
        return true
    }

    func format(_ amount: Decimal) -> String {
        formatter.format(amount, currencyCode: currencyCode, showBTC: showingBTC) ?? ""
    }

    private var canShowBTC: Bool {
        formatter.format(0, currencyCode: currencyCode, showBTC: true) != nil
    }
}
