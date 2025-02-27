//
//  RealTimeFees.swift
//  core-all
//
//  Created by Daniel Mankowski on 28/08/2024.
//

import Foundation

public struct RealTimeFees {

    let feeBumpFunctions: FeeBumpFunctions
    let feeWindow: FeeWindow
    let minMempoolFeeRateInSatPerVbyte: Double
    let minFeeRateIncrementToReplaceByFeeInSatPerVbyte: Double
    let computedAt: Date
}
