//
//  BlockHelperTests.swift
//  falconTests
//
//  Created by Manu Herrera on 02/08/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest
@testable import falcon

class BlockHelperTests: MuunTestCase {

    func testCertainty() {
        let results1Block = [64, 134, 215, 307, 416, 550, 723, 966, 1382]
        let results100Block = [52451, 54901, 56715, 58296, 59801, 61331, 62996, 64983, 67807]
        let results1000Block = [575817, 583976, 589908, 595007, 599801, 604619, 609803, 615908, 624441]

        let computedArrayFor1Block = (1..<10).map {
            BlockHelper.timeInSecs(numBlocks: 1, certainty: Double($0)/10)
        }
        let computedArrayFor100Block = (1..<10).map {
            BlockHelper.timeInSecs(numBlocks: 100, certainty: Double($0)/10)
        }
        let computedArrayFor1000Block = (1..<10).map {
            BlockHelper.timeInSecs(numBlocks: 1000, certainty: Double($0)/10)
        }
        
        XCTAssert(computedArrayFor1Block.elementsEqual(results1Block))
        XCTAssert(computedArrayFor100Block.elementsEqual(results100Block))
        XCTAssert(computedArrayFor1000Block.elementsEqual(results1000Block))
    }

    func testUIConfirmationTimes() {
        let blockTargets: [UInt] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 30, 43, 50, 90, 100, 150]
        let results = ["30m", "30m", "1h", "1h", "1h 30m", "1h 30m", "1h 30m", "2h", "2h", "2h", "2h 30m", "3h",
                       "4h", "6h", "8h", "10h", "17h", "18h", "27h"]

        let computedResults = blockTargets.map { BlockHelper.timeFor($0) }

        XCTAssert(computedResults.elementsEqual(results))
    }

}
