//
//  RealTimeData.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

struct RealTimeDataJson: Codable {

    let feeWindow: FeeWindowJson
    let exchangeRateWindow: ExchangeRateWindowJson
    let currentBlockchainHeight: Int
    let forwardingPolicies: [ForwardingPolicyJson]
    let minFeeRateInWeightUnits: Double

}

struct FeeWindowJson: Codable {
    let id: Int
    let fetchDate: Date

    // Here targeted fees is in sats/WU
    let targetedFees: [Int: Double]

    let fastConfTarget: UInt
    let mediumConfTarget: UInt
    let slowConfTarget: UInt
}

struct ExchangeRateWindowJson: Codable {
    let id: Int
    let fetchDate: Date
    let rates: [String: Double]
}
