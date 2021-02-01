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

        return Decimal(rate)
    }

    enum Errors: Error {
        case unknown(currency: String, window: Int)
    }
}
