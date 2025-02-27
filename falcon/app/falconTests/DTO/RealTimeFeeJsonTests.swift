//
//  RealTimeFeeJSONMTests.swift
//  falconTests
//
//  Created by Daniel Mankowski on 23/09/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import XCTest
import RxBlocking

@testable import Muun

final class RealTimeFeeJsonTests: XCTestCase {
    let json = """
{
    "computedAt": "2024-09-23T22:17:29.898219Z",
    "feeBumpFunctions": {
        "uuid": "testID",
        "functions":
            [
                "function1"
            ],
    },
    "minFeeRateIncrementToReplaceByFeeInSatPerVbyte": 1,
    "minMempoolFeeRateInSatPerVbyte": 1,
    "targetFeeRates": {
        "confTargetToTargetFeeRateInSatPerVbyte": {
            "1": 400,
            "10": 280,
            "15": 120,
            "150": 1,
            "90": 8
        },
        "fastConfTarget": 1,
        "mediumConfTarget": 43,
        "slowConfTarget": 90,
        "zeroConfSwapConfTarget": 250,
    }
}
""".data(using: .utf8)!

    func testDecodeRealTimeFeeJson() throws {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .customISO8601
        let realTimeFeeJson = try jsonDecoder.decode(RealTimeFeesJson.self, from: json)

        XCTAssertEqual(realTimeFeeJson.feeBumpFunctions.uuid, "testID")
        XCTAssertEqual(realTimeFeeJson.feeBumpFunctions.functions.count, 1)
        XCTAssertEqual(realTimeFeeJson.minFeeRateIncrementToReplaceByFeeInSatPerVbyte, 1)
        XCTAssertEqual(realTimeFeeJson.minMempoolFeeRateInSatPerVbyte, 1)
        XCTAssertEqual(realTimeFeeJson.targetFeeRates.confTargetToTargetFeeRateInSatPerVbyte.count, 5)
        XCTAssertEqual(realTimeFeeJson.targetFeeRates.fastConfTarget, 1)
        XCTAssertEqual(realTimeFeeJson.targetFeeRates.mediumConfTarget, 43)
        XCTAssertEqual(realTimeFeeJson.targetFeeRates.slowConfTarget, 90)
        XCTAssertEqual(realTimeFeeJson.targetFeeRates.zeroConfSwapConfTarget, 250)

        let realTimeFee = realTimeFeeJson.toModel()

        XCTAssertEqual(realTimeFee.feeBumpFunctions.uuid, "testID")
        XCTAssertEqual(realTimeFee.feeBumpFunctions.functions.count, 1)
        XCTAssertEqual(realTimeFee.minFeeRateIncrementToReplaceByFeeInSatPerVbyte, 1)
        XCTAssertEqual(realTimeFee.minMempoolFeeRateInSatPerVbyte, 1)
        XCTAssertEqual(realTimeFee.feeWindow.id, 1)
        XCTAssertEqual(realTimeFee.feeWindow.fastConfTarget, 1)
        XCTAssertEqual(realTimeFee.feeWindow.mediumConfTarget, 43)
        XCTAssertEqual(realTimeFee.feeWindow.slowConfTarget, 90)
        XCTAssertEqual(realTimeFee.feeWindow.targetedFees.count, 5)
    }
}
