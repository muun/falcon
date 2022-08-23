//
//  MonetaryAmount+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

extension MonetaryAmount {

    /// If you have the complete currency use toAmountPlusCode(btcCurrencyFormat:currencyOfAmount:) instead.
    /// > Warning: This method will default fiat for formatting if currency is not found.
    /// Default bitcoinUnit will be use in case of Bitcoin.
    func toAmountPlusCode(btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        let currencyFromCode = GetCurrencyForCode().runDefaultingFiat(code: currency)
        return toAmountPlusCode(btcCurrencyFormat: btcCurrencyFormat, currencyOfAmount: currencyFromCode)
    }

    func toAmountPlusCode(btcCurrencyFormat: BitcoinCurrencyFormat = .long, currencyOfAmount: Currency) -> String {
        let amountString = currencyOfAmount.toAmountWithoutCode(amount: amount,
                                                                btcCurrencyFormat: btcCurrencyFormat)
        let code = currencyOfAmount.displayCode

        return "\(amountString) \(code)"
    }

    func toAmountWithoutCode(btcCurrencyFormat: BitcoinCurrencyFormat = .long, currencyOfAmount: Currency) -> String {
        return currencyOfAmount.toAmountWithoutCode(amount: amount,
                                                    btcCurrencyFormat: btcCurrencyFormat)
    }

    /// If you have the complete currency use toAmountWithoutCode(btcCurrencyFormat:,currencyOfAmount:) instead.
    /// > Warning: This method will default fiat for formatting if currency is not found.
    /// Default bitcoinUnit will be use in case of Bitcoin.
    func toAmountWithoutCode(btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        let currencyOfAmount = GetCurrencyForCode().runDefaultingFiat(code: currency)
        return currencyOfAmount.toAmountWithoutCode(amount: amount,
                                                    btcCurrencyFormat: btcCurrencyFormat)
    }

    func toAttributedString(with font: UIFont) -> NSAttributedString {
        let amountString = toAmountWithoutCode()
        let attributedString = NSMutableAttributedString(
            string: "\(amountString) \(CurrencyHelper.string(for: currency))",
            attributes: [NSAttributedString.Key.font: font])
        return attributedString.set(tint: amountString, color: Asset.Colors.title.color)
    }

}
