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

    func toString(btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        let amountString = LocaleAmountFormatter.string(from: self, btcCurrencyFormat: btcCurrencyFormat)
        return "\(amountString) \(CurrencyHelper.string(for: currency))"
    }

    func toAttributedString(with font: UIFont) -> NSAttributedString {
        let amountString = LocaleAmountFormatter.string(from: self)
        let attributedString = NSMutableAttributedString(
            string: "\(amountString) \(CurrencyHelper.string(for: currency))",
            attributes: [NSAttributedString.Key.font: font])

        return attributedString.set(tint: amountString, color: Asset.Colors.title.color)
    }

}
