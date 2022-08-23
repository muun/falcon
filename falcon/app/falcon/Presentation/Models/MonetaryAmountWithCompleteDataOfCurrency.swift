//
//  MonetaryAmountWithCompleteDataOfCurrency.swift
//  falconTests
//
//  Created by Lucas Serruya on 11/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

/// MonetaryAmount is an object consumed by libWallet as well its really expensive to modify.
/// This struct is needed in order to have complete access to currency when interacting with monetary amount
struct MonetaryAmountWithCompleteDataOfCurrency {
    var monetaryAmount: MonetaryAmount
    private (set) var currency: Currency

    func toAmountWithoutCode(btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        currency.toAmountWithoutCode(amount: monetaryAmount.amount, btcCurrencyFormat: btcCurrencyFormat)
    }

    func toAmountPlusCode(btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        return monetaryAmount.toAmountPlusCode(btcCurrencyFormat: btcCurrencyFormat, currencyOfAmount: currency)
    }
}
