//
//  LocaleNumberFormatter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 19/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

struct LocaleAmountFormatter {

    static private(set) var locale = Locale.autoupdatingCurrent
    static private let btcFormatter = { () -> NumberFormatter in
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.currencySymbol = "BTC"
        formatter.currencyCode = "BTC"
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 8

        return formatter
    }()

    static func formatter(
        for currency: String,
        style: NumberFormatter.Style = .currency
    ) -> NumberFormatter {

        if currency == "BTC" {
            return btcFormatter
        }

        // This obtains the current locale targetted at the given currency
        let id = "\(locale.identifier)@currency=\(currency)"
        let canonical = NSLocale.canonicalLocaleIdentifier(from: id)
        let currencyLocale = Locale(identifier: canonical)

        let formatter = NumberFormatter()
        formatter.currencyCode = currency
        formatter.locale = currencyLocale
        formatter.numberStyle = style
        formatter.currencySymbol = ""
        formatter.roundingMode = .halfEven // Half even is the other name for bankers

        return formatter
    }

    static func format(string: String, in currency: String) -> String {

        let scale = formatter(for: currency).maximumFractionDigits

        var newString = string
        // Remove thousand separators so that the number can
        // be parsed when adding things in the middle
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
            let formattedIntegerPart = LocaleAmountFormatter.addGroupingSeparator(
                locale,
                integerPart
            )
            return formattedIntegerPart + decimalSeperator + decimalPart

        } else {
            return LocaleAmountFormatter.addGroupingSeparator(locale, newString)
        }
    }

    static func number(from value: String, in currency: String) -> MonetaryAmount? {
        guard let amount =
                formatter(for: currency, style: .decimal)
            .number(from: value)?
            .decimalValue else {
            return nil
        }

        return MonetaryAmount(amount: amount, currency: currency)
    }

    static func isSeparator(_ string: String) -> Bool {
        return locale.decimalSeparator == string || locale.groupingSeparator == string
    }

    static func string(from amount: MonetaryAmount) -> String {

        guard let value = formatter(for: amount.currency).string(for: amount.amount) else {
            fatalError()
        }

        // The currency formatter returns a leading space in numbers so kill it
        return value.trimmingCharacters(in: .whitespaces)

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

    // This next two methods are for our testing harness exclusively
    static func testing_setLocale(_ locale: Locale) {
        LocaleAmountFormatter.locale = locale
    }

}

public struct MonetaryAmount {
    public let amount: Decimal
    public let currency: String

    public init(amount: Decimal, currency: String) {
        self.amount = amount
        self.currency = currency
    }

    public init?(amount: String, currency: String) {

        guard let amount = Decimal(string: amount, locale: Locale.init(identifier: "en_US")) else {
            return nil
        }

        self.init(amount: amount, currency: currency)
    }

}
