//
//  Currency.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

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
