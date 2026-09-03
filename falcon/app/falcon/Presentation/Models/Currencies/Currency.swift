//
//  Currency.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation
import Libwallet

public let satSymbol = "SAT"

protocol Currency {
    var code: String { get }
    var symbol: String { get }
    var name: String { get }
    var flag: String? { get }
    var displayExponent: Int16 { get }
    var displayCode: String { get }
    var maximumFractionDigits: Int { get }
    func toAmountWithoutCode(amount: Decimal, btcCurrencyFormat: BitcoinCurrencyFormat) -> String
    func formattedNumber(from value: String) -> MonetaryAmount
}

extension Currency {
    var displayCode: String {
        return code
    }

    var displayExponent: Int16 {
        return Int16(0)
    }

    // A currency with a missing, zero or NaN rate can't be converted: forwarding it to
    // libwallet's amount conversion would divide by the rate and crash (#16412). Bitcoin is
    // always valid — its rate is structurally 1.
    func hasValidRate(in window: NewopExchangeRateWindow) -> Bool {
        if self is BitcoinCurrency {
            return true
        }

        return window.rate(code).isUsableExchangeRate
    }
}

func == (lhs: BitcoinCurrency, rhs: BitcoinCurrency) -> Bool {
    return lhs.code == rhs.code && lhs.unit == rhs.unit
}

func == (lhs: Currency, rhs: Currency) -> Bool {
    guard let lhs = lhs as? BitcoinCurrency, let rhs = rhs as? BitcoinCurrency else {
        return lhs.code == rhs.code
    }

    return lhs == rhs
}
