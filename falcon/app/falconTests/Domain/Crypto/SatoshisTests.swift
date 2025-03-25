//
//  SatoshisTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 18/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import XCTest

@testable import Muun

// These are all really dumb tests, but they test a very core part of the logic that
// would be really easy to fat finger into subtle errors
class SatoshisTests: XCTestCase {
    
    func testConvertToBTC() {
        let satoshis = Satoshis(value: 1000)
        XCTAssertEqual(satoshis.toBTC(), MonetaryAmount(amount: "0.00001", currency: "BTC"))
    }
    
    func testExchangeRate() {
        let satoshis = Satoshis(value: 1000)
        XCTAssertEqual(satoshis.valuation(at: 10, currency: "USD"),
                       MonetaryAmount(amount: "0.0001", currency: "USD"))
    }
    
    func testBasicOps() {
        let val1 = Satoshis(value: 1000)
        let val2 = Satoshis(value: 100)
        
        XCTAssertEqual((val1 - val2).value, 900)
        XCTAssertEqual((val1 + val2).value, 1100)
        XCTAssertEqual((-val2).value, -100)
    }
}

extension MonetaryAmount: Equatable {

    public static func == (lhs: MonetaryAmount, rhs: MonetaryAmount) -> Bool {
        return lhs.amount == rhs.amount && lhs.currency == rhs.currency
    }

}
