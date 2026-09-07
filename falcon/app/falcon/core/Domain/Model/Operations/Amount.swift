//
//  Amount.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

/// An absolute value represented in satoshis, currency selected by user (inputCurrency) and
/// currency selected by default (primaryCurrency)
public struct BitcoinAmount {
    public let inSatoshis: Satoshis
    public let inInputCurrency: MonetaryAmount
    public let inPrimaryCurrency: MonetaryAmount

    public init(
        inSatoshis: Satoshis,
        inInputCurrency: MonetaryAmount,
        inPrimaryCurrency: MonetaryAmount
    ) {
        self.inSatoshis = inSatoshis
        self.inInputCurrency = inInputCurrency
        self.inPrimaryCurrency = inPrimaryCurrency
    }
}

extension BitcoinAmount: Comparable {

    public static func < (lhs: BitcoinAmount, rhs: BitcoinAmount) -> Bool {
        return lhs.inSatoshis < rhs.inSatoshis
    }

    public static func == (lhs: BitcoinAmount, rhs: BitcoinAmount) -> Bool {
        return lhs.inSatoshis == rhs.inSatoshis
    }

}

extension BitcoinAmount {

    public static func from(
        inputCurrency inInputCurrency: MonetaryAmount,
        with window: ExchangeRateWindow,
        primaryCurrency: String
    ) -> BitcoinAmount {

        func rate(for currency: String) -> Decimal {
            // An unusable or missing rate degrades to 0: Satoshis.from then yields a 0 amount
            // (and reports the degradation) instead of crashing.
            return window.displayRate(for: currency) ?? 0
        }

        return from(inputCurrency: inInputCurrency, rate: rate, primaryCurrency: primaryCurrency)
    }

    public static func from(
        inputCurrency inInputCurrency: MonetaryAmount,
        rate: (String) -> Decimal,
        primaryCurrency: String
    ) -> BitcoinAmount {

        let rateForInput = rate(inInputCurrency.currency)
        let satoshis = Satoshis.from(amount: inInputCurrency.amount, at: rateForInput)

        let inPrimaryCurrency: MonetaryAmount
        if inInputCurrency.currency == primaryCurrency {
            inPrimaryCurrency = inInputCurrency
        } else {
            inPrimaryCurrency = satoshis.valuation(
                at: rate(primaryCurrency),
                currency: primaryCurrency
            )
        }

        return BitcoinAmount(
            inSatoshis: satoshis,
            inInputCurrency: inInputCurrency,
            inPrimaryCurrency: inPrimaryCurrency
        )
    }

    public static func from(
        satoshis: Satoshis,
        with window: ExchangeRateWindow,
        mirroring mirror: BitcoinAmount
    ) -> BitcoinAmount {

        func valuation(for currency: String) -> MonetaryAmount {
            // An unusable or missing rate degrades to a 0 amount in that currency instead of
            // crashing the conversion.
            guard let rate = window.displayRate(for: currency) else {
                return MonetaryAmount(amount: 0, currency: currency)
            }
            return satoshis.valuation(at: rate, currency: currency)
        }

        return BitcoinAmount(
            inSatoshis: satoshis,
            inInputCurrency: valuation(for: mirror.inInputCurrency.currency),
            inPrimaryCurrency: valuation(for: mirror.inPrimaryCurrency.currency)
        )
    }

}

public struct Satoshis {
    public static let magnitude: Int16 = 8
    public static let dust = Satoshis(value: 3 * 182)
    public static let zero = Satoshis(value: 0)

    public let value: Int64

    public init(value: Int64) {
        self.value = value
    }
}

extension Satoshis {

    public func asDecimal() -> Decimal {
        return Decimal(value)
    }

    public func toBTCDecimal() -> Decimal {
        return asDecimal().multiplyByPowerOf10(power: -Satoshis.magnitude)
    }

    public func toBTC() -> MonetaryAmount {
        return MonetaryAmount(amount: toBTCDecimal(), currency: "BTC")
    }

    public func valuation(at exchangeRate: Decimal, currency: String) -> MonetaryAmount {
        return MonetaryAmount(
            amount: toBTCDecimal() * exchangeRate,
            currency: currency
        )
    }

    // This method creates a bitcoin amount model from a Satoshis model
    // with a reference BitcoinAmount model.
    // It uses the reference to apply a rule of three and calculates how much $ are worth those sats
    // in the primary currency of the reference.
    // This method should only be used for display purposes.
    public func toBitcoinAmount(reference: BitcoinAmount) -> BitcoinAmount {
        let amountInPrimary = self.asDecimal() * reference.inPrimaryCurrency.amount
            / reference.inSatoshis.asDecimal()
        let inPrimary = MonetaryAmount(
            amount: amountInPrimary,
            currency: reference.inPrimaryCurrency.currency
        )
        return BitcoinAmount(
            inSatoshis: self,
            inInputCurrency: toBTC(),
            inPrimaryCurrency: inPrimary
        )
    }

    public static func bounded(amount: Decimal, at rate: Decimal) throws -> Satoshis {
        guard rate.isUsableExchangeRate else {
            throw MuunError(Errors.invalidRate)
        }

        let decimalValue = (amount / rate).multiplyByPowerOf10(power: Satoshis.magnitude)

        // We multiply by 1000 to account for millisat convertions
        if decimalValue * 1000 > Decimal(Int64.max) {
            throw MuunError(Errors.amountNotRepresentable)
        }

        // We HAVE to round before converting, otherwise some strange things happen
        // Rounding down makes sense for satoshi amounts: 1 satoshi is too small a number to
        // complain about
        let rounded = decimalValue.round(scale: 0, roundingMode: .bankers)

        return Satoshis(value: NSDecimalNumber(decimal: rounded).int64Value)
    }

    @available(*, deprecated, message: "Use bounded(amount:at:) to prevent silent overflows")
    public static func from(amount: Decimal, at rate: Decimal) -> Satoshis {
        // Dividing by a zero/NaN rate yields NaN, which crashes multiplyByPowerOf10.
        // Degrade to 0 instead of crashing, mirroring Apollo's behavior with invalid rates.
        guard rate.isUsableExchangeRate else {
            // Report the degradation so we notice an upstream feeding invalid rates. A plain
            // NSError groups by callsite (not by message), so the offending rate can live in the
            // description without fragmenting the Crashlytics issue.
            Logger.log(error: NSError(
                domain: "satoshis_from_invalid_rate",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey:
                    "Satoshis.from called with invalid rate: \(rate)"]
            ))
            return Satoshis.zero
        }

        let decimalValue = (amount / rate).multiplyByPowerOf10(power: Satoshis.magnitude)

        // We HAVE to round before converting, otherwise some strange things happen
        // Rounding down makes sense for satoshi amounts: 1 satoshi is too small a number to
        // complain about
        let rounded = decimalValue.round(scale: 0, roundingMode: .bankers)

        return Satoshis(value: NSDecimalNumber(decimal: rounded).int64Value)
    }

    public static func from(bitcoin: Decimal) -> Satoshis {
        // Bitcoin rate is 1
        return from(amount: bitcoin, at: 1)
    }

    public static func + (lhs: Satoshis, rhs: Satoshis) -> Satoshis {
        return Satoshis(value: lhs.value + rhs.value)
    }

    public static func - (lhs: Satoshis, rhs: Satoshis) -> Satoshis {
        return Satoshis(value: lhs.value - rhs.value)
    }

    public static prefix func - (lhs: Satoshis) -> Satoshis {
        return Satoshis(value: -lhs.value)
    }

    public static func * (lhs: Satoshis, rhs: Int64) -> Satoshis {
        return Satoshis(value: lhs.value * rhs)
    }

    public static func calculateFee(feePerVByte: Decimal, sizeInVBytes: Int64) -> Satoshis {
        let decimalSize = Decimal(sizeInVBytes)
        let decimalSatoshis = (feePerVByte * decimalSize).round(
            scale: 0,
            roundingMode: .up
        ) as NSDecimalNumber

        return Satoshis(value: decimalSatoshis.int64Value)
    }

    public static func += (lhs: inout Satoshis, rhs: Satoshis) {
        lhs = Satoshis(value: lhs.value + rhs.value)
    }

    public static func -= (lhs: inout Satoshis, rhs: Satoshis) {
        lhs = Satoshis(value: lhs.value - rhs.value)
    }

    enum Errors: Error {
        case amountNotRepresentable
        case invalidRate
    }

}

extension Satoshis: Codable {}

extension Satoshis: Comparable {

    public static func < (lhs: Satoshis, rhs: Satoshis) -> Bool {
        return lhs.value < rhs.value
    }

}

public struct FeeRate: Codable, Equatable {
    public let satsPerVByte: Decimal

    public var satsPerWeightUnit: Decimal {
        return satsPerVByte / 4
    }

    public init(satsPerWeightUnit: Decimal) {
        // 1 sat/WU is equal to 4 sat/vByte
        self.satsPerVByte = satsPerWeightUnit * 4
    }

    public init(satsPerVByte: Decimal) {
        self.satsPerVByte = satsPerVByte
    }

    public func calculateFee(sizeInWeightUnit: Int64) -> Satoshis {
        // WeightUnit divided by 4 gives us the size in vBytes
        let decimalSizeInVirtualBytes = Decimal(sizeInWeightUnit) / 4
        let decimalSatoshis = (satsPerVByte * decimalSizeInVirtualBytes).round(
            scale: 0,
            roundingMode: .up
        ) as NSDecimalNumber

        return Satoshis(value: decimalSatoshis.int64Value)
    }

    public func rounded() -> Decimal {
        return satsPerVByte.round(scale: 2, roundingMode: .up)
    }

    public func stringValue() -> String {
        return rounded().stringValue()
    }

}

extension Satoshis.Errors: ClassifiedError {
    var classification: ErrorClassification {
        switch self {
        case .amountNotRepresentable, .invalidRate:
            return .unexpected
        }
    }
}
