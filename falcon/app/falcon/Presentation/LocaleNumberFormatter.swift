//
//  LocaleNumberFormatter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 19/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

import Dip

enum BitcoinCurrencyFormat {
    case long // Always uses 8 decimals
    case short // Uses at least 2 decimals and up to 8.

    func minimumFractionDigits() -> Int {
        switch self {
        case .long: return 8
        case .short: return 2
        }
    }
}

struct LocaleAmountFormatter: Resolver {

    private static let preferences: Preferences = resolve()

    static private(set) var locale = Locale.autoupdatingCurrent
    static private func btcFormatter(format: BitcoinCurrencyFormat) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.currencySymbol = "BTC"
        formatter.currencyCode = "BTC"
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = format.minimumFractionDigits()

        return formatter
    }

    static private let satFormatter = { () -> NumberFormatter in
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.currencySymbol = satSymbol
        formatter.currencyCode = satSymbol
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    static private let decimalFormatter = { () -> NumberFormatter in
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal

        return formatter
    }()

    static func format(string: String, in currency: Currency) -> String {

        let scale = currency.maximumFractionDigits

        var newString = string
        // Remove thousand separators so that the number
        // can be parsed when adding things in the middle
        if let groupingSeperator = locale.groupingSeparator {
            newString = newString.replacingOccurrences(of: groupingSeperator, with: "")
        }

        // Remove leading zeros
        let firstNonZero = newString.firstIndex(where: { $0 != "0" }) ?? newString.endIndex
        let numberOfZeros = newString.distance(from: newString.startIndex, to: firstNonZero)
        newString = String(newString.dropFirst(max(numberOfZeros - 1, 0)))

        if let decimalSeperator = locale.decimalSeparator,
            let range = newString.range(of: decimalSeperator) {

            let integerPart = String(newString.prefix(upTo: range.lowerBound))
            let decimalPart: String

            if range.upperBound < string.endIndex {
                decimalPart = String(newString.suffix(from: range.upperBound).prefix(scale))
            } else {
                decimalPart = ""
            }

            return LocaleAmountFormatter.addGroupingSeparator(
                locale,
                integerPart
            ) + decimalSeperator + decimalPart

        } else {
            return LocaleAmountFormatter.addGroupingSeparator(locale, newString)
        }
    }

    static func number(from value: String) -> Decimal? {
        return decimalFormatter.number(from: value)?.decimalValue
    }

    static func isSeparator(_ string: String) -> Bool {
        return locale.decimalSeparator == string || locale.groupingSeparator == string
    }

    static private func addGroupingSeparator(_ locale: Locale, _ string: String) -> String {
        var newString = string
        if let groupingSeparator = locale.groupingSeparator {
            // We sub one since we need
            let parts = (newString.count - 1) / 3
            for i in 0..<parts {
                let index = newString.index(newString.endIndex, offsetBy: -3 * (i + 1) - i)
                newString.insert(contentsOf: groupingSeparator, at: index)
            }
        }

        return newString
    }

    enum Errors: Error {
        case format(value: Decimal, currency: String, locale: String)
    }
}

extension LocaleAmountFormatter {

    // This next method is for our testing harness exclusively
    static func testing_setLocale(_ locale: Locale) {
        LocaleAmountFormatter.locale = locale
    }

}
