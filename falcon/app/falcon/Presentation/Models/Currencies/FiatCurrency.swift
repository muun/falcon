//
//  FiatCurrency.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import CoreFoundation
import Foundation

struct FiatCurrency: Currency {
    let code: String
    let symbol: String
    let name: String
    let flag: String?
    var maximumFractionDigits: Int {
        return getNumberFormatter(style: .currency).maximumFractionDigits
    }

    func toAmountWithoutCode(amount: Decimal, btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        let formatter = getFormatter(numberStyle: .currency, currencyCode: code)

        guard let value = formatter.string(for: amount) else {
            let localeDescription = LocaleAmountFormatter.locale.description
            Logger.fatal(error: MuunError(LocaleAmountFormatter.Errors.format(value: amount,
                                                                              currency: code,
                                                                              locale: localeDescription)))
        }

        // The currency formatter returns a leading space in numbers so kill it
        return value.trimmingCharacters(in: .whitespaces)
    }

    func formattedNumber(from value: String) -> MonetaryAmount {
        let formatter = getNumberFormatter()
        // Try to parse the amount or return 0 if it's not a valid input like ","
        var amount = formatter.number(from: value)?.decimalValue ?? 0
        amount = amount.multiplyByPowerOf10(power: -self.displayExponent)
        return MonetaryAmount(amount: amount, currency: self.code)
    }

    private func getNumberFormatter(style: NumberFormatter.Style = .decimal) -> NumberFormatter {
// This obtains the current locale targetted at the given currency
        return getFormatter(numberStyle: style, currencyCode: self.code)
    }

    private func getFormatter(numberStyle: NumberFormatter.Style, currencyCode: String) -> NumberFormatter {
        let id = "\(LocaleAmountFormatter.locale.identifier)@currency=\(currencyCode)"
        let canonical = NSLocale.canonicalLocaleIdentifier(from: id)
        let currencyLocale = Locale(identifier: canonical)
        let formatter = NumberFormatter()
        // The formatter might have inconsistent behavior if the numberStyle is not
        // currency but currency values are setted
        if numberStyle == .currency {
            formatter.currencyCode = currencyCode
            formatter.currencySymbol = ""
            formatter.currencyDecimalSeparator = LocaleAmountFormatter.locale.decimalSeparator
            formatter.currencyGroupingSeparator = LocaleAmountFormatter.locale.groupingSeparator
        }

        formatter.locale = currencyLocale
        formatter.numberStyle = numberStyle

        // This may seem redundant, but we encountered unexpected behavior with currencies
        // not respecting the locale. Ensure the formatter adheres to the locale settings.
        // I checked if th problem was how we were generating the ID but the ID generation
        // seems to be okey.
        formatter.decimalSeparator = LocaleAmountFormatter.locale.decimalSeparator
        formatter.groupingSeparator = LocaleAmountFormatter.locale.groupingSeparator
        formatter.roundingMode = .halfEven // Half even is the other name for bankers

        return formatter
    }
}
