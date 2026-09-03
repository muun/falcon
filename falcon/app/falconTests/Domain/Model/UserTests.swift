//
//  DateTests.swift
//  falconTests
//
//  Created by Manu Herrera on 23/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest
import Libwallet

@testable import Muun

class UserTests: MuunTestCase {

    func testSupportId() {
        var user = Factory.user(createdAt: Date(timeIntervalSinceReferenceDate: 614635838.145))

        XCTAssert(user.getSupportId() == "9294-3038")

        let dateFormatter = Formatter.iso8601
        guard let decodedDate = dateFormatter.date(from: "1995-03-18T12:30:00.45+00:00") else {
            fatalError("Error decoding ISO8601 date")
        }

        user = Factory.user(createdAt: decodedDate)
        XCTAssert(user.getSupportId() == "9552-9800")
    }

    func testPrimaryCurrencyWithValidExchangeRate() {
        // Factory user has USD as primary currency
        let user = Factory.user()

        let valid = ExchangeRateWindow(id: 1, fetchDate: Date(), rates: ["USD": 100])
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: valid), "USD")

        let zeroRate = ExchangeRateWindow(id: 1, fetchDate: Date(), rates: ["USD": 0])
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: zeroRate), "BTC")

        let nanRate = ExchangeRateWindow(id: 1, fetchDate: Date(), rates: ["USD": Double.nan])
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: nanRate), "BTC")

        let missingRate = ExchangeRateWindow(id: 1, fetchDate: Date(), rates: ["EUR": 100])
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: missingRate), "BTC")
    }

    func testPrimaryCurrencyWithValidExchangeRateNewop() {
        // Factory user has USD as primary currency
        let user = Factory.user()

        let valid = NewopExchangeRateWindow()
        valid.addRate("USD", rate: 100)
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: valid), "USD")

        let zeroRate = NewopExchangeRateWindow()
        zeroRate.addRate("USD", rate: 0)
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: zeroRate), "BTC")

        let nanRate = NewopExchangeRateWindow()
        nanRate.addRate("USD", rate: Double.nan)
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: nanRate), "BTC")

        let missingRate = NewopExchangeRateWindow()
        missingRate.addRate("EUR", rate: 100)
        XCTAssertEqual(user.primaryCurrencyWithValidExchangeRate(window: missingRate), "BTC")
    }

}
