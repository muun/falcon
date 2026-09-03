//
//  RealTimeData.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public struct RealTimeData {

    let feeWindow: FeeWindow
    let exchangeRateWindow: ExchangeRateWindow
    let currentBlockchainHeight: Int
    let forwardingPolicies: [ForwardingPolicy]
    let minFeeRateInWeightUnits: Double
    let features: [FeatureFlags]
}

public struct FeeWindow: Codable {
    let id: Int
    let fetchDate: Date

    public let targetedFees: [UInt: FeeRate]

    // These properties are optional for retrocompat motives only.
    // But they'll never be optional in build versions > 46.
    public let fastConfTarget: UInt?
    public let mediumConfTarget: UInt?
    public let slowConfTarget: UInt?
}

public struct ExchangeRateWindow: Codable {
    public let id: Int
    let fetchDate: Date
    public let rates: [String: Double]

    init(id: Int, fetchDate: Date, rates: [String: Double]) {
        self.id = id
        self.fetchDate = fetchDate
        self.rates = rates
    }

    public func rate(for currency: String) throws -> Decimal {
        guard let rate = rates[currency] else {
            throw MuunError(Errors.unknown(currency: currency, window: id))
        }

        // A zero/negative/NaN rate can't be used for conversions: treat it as missing so
        // every consumer handles it through the same path.
        guard rate.isUsableExchangeRate else {
            throw MuunError(Errors.invalid(currency: currency, rate: rate, window: id))
        }

        return Decimal(rate)
    }

    /// The rate for `currency`, or nil when it's missing or unusable (zero/negative/NaN).
    /// Display conversions that must degrade to a zero amount rather than crash use this
    /// instead of `rate(for:)`. Reporting of unusable rates lives in the conversion
    /// primitives (`Satoshis.from`) and the primary-currency checks, so this stays a pure
    /// accessor and avoids double-reporting the same degradation.
    func displayRate(for currency: String) -> Decimal? {
        do {
            return try rate(for: currency)
        } catch {
            return nil
        }
    }

    enum Errors: Error {
        case unknown(currency: String, window: Int)
        case invalid(currency: String, rate: Double, window: Int)
    }
}

extension ExchangeRateWindow.Errors: ClassifiedError {
    var classification: ErrorClassification {
        switch self {
        case .unknown, .invalid:
            return .unexpected
        }
    }
}

extension Double {
    /// A rate usable for currency conversion: strictly positive and not NaN. Dividing an
    /// amount by a zero/negative/NaN rate either crashes or yields garbage, so every rate
    /// check in the app funnels through this single predicate.
    /// The `!isNaN` check is redundant (`NaN > 0` is already false) but kept on purpose to
    /// make the "no NaN rates" intent explicit. Don't drop it.
    var isUsableExchangeRate: Bool {
        return self > 0 && !isNaN
    }
}

extension Decimal {
    /// See `Double.isUsableExchangeRate`.
    var isUsableExchangeRate: Bool {
        return self > 0 && !isNaN
    }
}
