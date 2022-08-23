//
//  LocaleNumberFormatterTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 19/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest
@testable import core
@testable import Muun

class LocaleNumberFormatterTests: MuunTestCase {
    lazy var usdCurrency = CurrencyHelper.allCurrencies["USD"]!
    func testFormat() {
        LocaleAmountFormatter.testing_setLocale(Locale(identifier: "es_AR"))

        // Grouping tests
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123",
                                                    in: usdCurrency), "123")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "1231",
                                                    in: usdCurrency), "1.231")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "23123",
                                                    in: usdCurrency), "23.123")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123123", in: usdCurrency), "123.123")

        // Decimal tests
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123,", in: usdCurrency), "123,")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "1123,", in: usdCurrency), "1.123,")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "1231,0", in: usdCurrency), "1.231,0")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "23123,1", in: usdCurrency), "23.123,1")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123123,153", in: usdCurrency), "123.123,15")

        // With previous separators
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123.123,153", in: usdCurrency), "123.123,15")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123.123,", in: usdCurrency), "123.123,")
    }
}
