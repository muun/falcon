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

    func testFormat() {
        LocaleAmountFormatter.testing_setLocale(Locale(identifier: "es_AR"))

        // Grouping tests
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123", in: "USD"), "123")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "1231", in: "USD"), "1.231")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "23123", in: "USD"), "23.123")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123123", in: "USD"), "123.123")

        // Decimal tests
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123,", in: "USD"), "123,")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "1123,", in: "USD"), "1.123,")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "1231,0", in: "USD"), "1.231,0")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "23123,1", in: "USD"), "23.123,1")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123123,153", in: "USD"), "123.123,15")

        // With previous separators
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123.123,153", in: "USD"), "123.123,15")
        XCTAssertEqual(LocaleAmountFormatter.format(string: "123.123,", in: "USD"), "123.123,")
    }

    func testDecimals() {
        LocaleAmountFormatter.testing_setLocale(Locale(identifier: "es_AR"))

        XCTAssertEqual(
            LocaleAmountFormatter.string(from: MonetaryAmount(amount: Decimal(0.123), currency: "USD")),
            "0,12"
        )

        XCTAssertEqual(
            LocaleAmountFormatter.string(from: MonetaryAmount(amount: Decimal(0.123), currency: "JPY")),
            "0"
        )

        // Bankers rounding
        XCTAssertEqual(
            LocaleAmountFormatter.string(from: MonetaryAmount(amount: Decimal(0.125), currency: "USD")),
            "0,12"
        )
        XCTAssertEqual(
            LocaleAmountFormatter.string(from: MonetaryAmount(amount: Decimal(0.135), currency: "USD")),
            "0,14"
        )
    }

    func testInvalidInputs() {
        LocaleAmountFormatter.testing_setLocale(Locale(identifier: "es_AR"))
        let zeroUsd = MonetaryAmount(amount: "0,00", currency: "USD")

        XCTAssertEqual(LocaleAmountFormatter.number(from: ",", in: "USD"), zeroUsd)
        XCTAssertEqual(LocaleAmountFormatter.number(from: ".", in: "USD"), zeroUsd)

        // These are not technically invalid inputs but that doesnt make them `useless` tests:
        XCTAssertEqual(LocaleAmountFormatter.number(from: "0.", in: "USD"), zeroUsd)
        XCTAssertEqual(LocaleAmountFormatter.number(from: "0,0", in: "USD"), zeroUsd)
        XCTAssertEqual(LocaleAmountFormatter.number(from: ",0", in: "USD"), zeroUsd)
        XCTAssertEqual(LocaleAmountFormatter.number(from: ".0", in: "USD"), zeroUsd)
    }

    func testBitcoinBalance() {
        let zeroBTC = MonetaryAmount(amount: "0", currency: "BTC")!
        XCTAssertEqual(LocaleAmountFormatter.string(from: zeroBTC), "0.00000000")
        XCTAssertEqual(LocaleAmountFormatter.string(from: zeroBTC, btcCurrencyFormat: .short), "0.00")

        let amountInBTC = MonetaryAmount(amount: "1.80395", currency: "BTC")!
        XCTAssertEqual(LocaleAmountFormatter.string(from: amountInBTC), "1.80395000")
        XCTAssertEqual(LocaleAmountFormatter.string(from: amountInBTC, btcCurrencyFormat: .short), "1.80395")

        let oneSatoshi =  MonetaryAmount(amount: "0.00000001", currency: "BTC")!
        XCTAssertEqual(LocaleAmountFormatter.string(from: oneSatoshi), "0.00000001")
        XCTAssertEqual(LocaleAmountFormatter.string(from: oneSatoshi, btcCurrencyFormat: .short), "0.00000001")
    }

    func testBalanceInSatoshis() {
        let preferences: Preferences = resolve()
        preferences.set(value: true, forKey: .displayBTCasSAT)

        let zeroBTC = MonetaryAmount(amount: "0", currency: "BTC")!
        XCTAssertEqual(LocaleAmountFormatter.string(from: zeroBTC), "0")
        XCTAssertEqual(zeroBTC.toString(), "0 SAT")

        let amountInBTC = MonetaryAmount(amount: "1.80395", currency: "BTC")!
        XCTAssertEqual(LocaleAmountFormatter.string(from: amountInBTC), "180,395,000")

        let oneSatoshi =  MonetaryAmount(amount: "0.00000001", currency: "BTC")!
        XCTAssertEqual(LocaleAmountFormatter.string(from: oneSatoshi), "1")
    }

}
