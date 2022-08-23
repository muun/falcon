//
//  BitcoinCurrency.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

enum BitcoinUnit {
    case BTC
    case SAT
}

/// BitcoinCurrency has a unit to choose between BTC and SATS.
/// If unit var is nil, unit will be choosen from .displayBTCasSAT in preferences.
struct BitcoinCurrency: Currency {
    let code = "BTC"

    var unit: BitcoinUnit?

    let symbol = ""

    var name: String {
        getValueByCurrentUnit(forBTC: "Bitcoin", forSAT: "Satoshi")
    }

    let flag: String? = nil

    var displayExponent: Int16 {
        getValueByCurrentUnit(forBTC: 0, forSAT: Satoshis.magnitude)
    }

    var displayCode: String {
        getValueByCurrentUnit(forBTC: code, forSAT: satSymbol)
    }

    var maximumFractionDigits: Int {
        getNumberFormatter(style: .currency).maximumFractionDigits
    }

    func toAmountWithoutCode(amount: Decimal, btcCurrencyFormat: BitcoinCurrencyFormat = .long) -> String {
        let amt = amount.multiplyByPowerOf10(power: displayExponent)

        let formatter = createStringFormatter(btcCurrencyFormat: btcCurrencyFormat)

        guard let value = formatter.string(for: amt) else {
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
        var amount = formatter.number(from: value)?.decimalValue ?? 0
        let magnitude = displayExponent
        amount = amount.multiplyByPowerOf10(power: -magnitude)

        return MonetaryAmount(amount: amount, currency: self.code)
    }
}

private extension BitcoinCurrency {
    func getNumberFormatter(style: NumberFormatter.Style = .decimal) -> NumberFormatter {
        getValueByCurrentUnit(forBTC: getBTCNumberFormmatter(style: style),
                              forSAT: createSATFormatterForStringAndNumber(style: style))
    }

    func createStringFormatter(btcCurrencyFormat: BitcoinCurrencyFormat) -> NumberFormatter {
        getValueByCurrentUnit(forBTC: createBTCFormatterForString(btcCurrencyFormat: btcCurrencyFormat),
                              forSAT: createSATFormatterForStringAndNumber())
    }

    func createBTCFormatterForString(btcCurrencyFormat: BitcoinCurrencyFormat) -> NumberFormatter {
        let formatter = createBasicBTCFormatterForBothNumberAndString()
        formatter.minimumFractionDigits = btcCurrencyFormat.minimumFractionDigits()
        return formatter
    }

    func getBTCNumberFormmatter(style: NumberFormatter.Style = .decimal) -> NumberFormatter {
        let formatter = createBasicBTCFormatterForBothNumberAndString(style: style)
        formatter.minimumFractionDigits = BitcoinCurrencyFormat.long.minimumFractionDigits()

        return formatter
    }

    func createBasicBTCFormatterForBothNumberAndString(style: NumberFormatter.Style = .decimal) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = LocaleAmountFormatter.locale
        formatter.numberStyle = style
        formatter.currencySymbol = "BTC"
        formatter.currencyCode = "BTC"
        formatter.maximumFractionDigits = 8

        return formatter
    }

    func createSATFormatterForStringAndNumber(style: NumberFormatter.Style = .decimal) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = LocaleAmountFormatter.locale
        formatter.numberStyle = style
        formatter.currencySymbol = satSymbol
        formatter.currencyCode = satSymbol
        formatter.maximumFractionDigits = 0
        return formatter
    }

    private func getValueByCurrentUnit<T: Any>(forBTC: T, forSAT: T) -> T {
        return getBitcoinUnit() == .SAT ? forSAT : forBTC
    }

    private func getBitcoinUnit() -> BitcoinUnit {
        guard let unit = unit else {
            return CurrencyHelper.preferences.bool(forKey: .displayBTCasSAT) ? .SAT : .BTC
        }

        return unit
    }
}
