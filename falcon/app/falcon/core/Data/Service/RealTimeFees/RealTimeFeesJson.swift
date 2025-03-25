//
//  RealTimeFeesJSON.swift
//  core-all
//
//  Created by Daniel Mankowski on 28/08/2024.
//

import Foundation

struct RealTimeFeesJson: Codable {

    let feeBumpFunctions: FeeBumpFunctionsJson
    let targetFeeRates: TargetedFeeRatesJson
    let minMempoolFeeRateInSatPerVbyte: Double
    let minFeeRateIncrementToReplaceByFeeInSatPerVbyte: Double
    let computedAt: Date
}

struct TargetedFeeRatesJson: Codable {

    let confTargetToTargetFeeRateInSatPerVbyte: [Int: Double]
    let fastConfTarget: UInt
    let mediumConfTarget: UInt
    let slowConfTarget: UInt
    let zeroConfSwapConfTarget: UInt
}

public enum FeeBumpRefreshPolicyJson: String, Codable {
    case foreground
    case periodic
    case newOpBlockingly
    case ntsChanged
}

// It contains the unconfirmed UTXOs that will be used to obtain the
// corresponding fee bump functions from realtime/fees API. The order
// passed here matches the order of the returned functions.
/// - feeBumpRefreshPolicy is used for tracking.
struct RealTimeFeesRequestJson: Codable {
    let unconfirmedOutpoints: [String]
    let feeBumpRefreshPolicy: FeeBumpRefreshPolicyJson?
}
