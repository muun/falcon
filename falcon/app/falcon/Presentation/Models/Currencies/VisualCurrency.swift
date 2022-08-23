//
//  VisualCurrency.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

/// Workaround to show multiples currencies with the same code on picker.
struct VisualCurrency: Currency {
    let code: String
    let symbol: String
    let name: String
    let flag: String?
    let maximumFractionDigits: Int = 0

    func toAmountWithoutCode(amount: Decimal, btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        fatalError("Visual Currencies can not be converted")
    }

    func formattedNumber(from value: String) -> MonetaryAmount {
        fatalError("Visual Currencies can not be converted")
    }
}
