//
//  FiatCurrencyTests.swift
//  falconTests
//
//  Created by Lucas Serruya on 13/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun
import XCTest
import core

class FiatCurrencyTest: XCTestCase {
    var currency: FiatCurrency!
    var currentMonetaryAmount: MonetaryAmount!
    var resultOfOperation: String!

    func testDecimals() {
        LocaleAmountFormatter.testing_setLocale(Locale(identifier: "es_AR"))
        
        given(amount: Decimal(0.123), currencyCode: "USD")
        whenAmountWithoutCodeIsRetrieved()
        then(expectedResult: "0,12")
        
        given(amount: Decimal(0.123), currencyCode: "JPY")
        whenAmountWithoutCodeIsRetrieved()
        then(expectedResult: "0")
        
        // Bankers rounding
        given(amount: Decimal(0.125), currencyCode: "USD")
        whenAmountWithoutCodeIsRetrieved()
        then(expectedResult: "0,12")
        
        given(amount: Decimal(0.135), currencyCode: "USD")
        whenAmountWithoutCodeIsRetrieved()
        then(expectedResult: "0,14")
    }

    func testInvalidInputs() {
        LocaleAmountFormatter.testing_setLocale(Locale(identifier: "es_AR"))
        lazy var usdCurrency = CurrencyHelper.allCurrencies["USD"]!
        let zeroUsd = MonetaryAmount(amount: "0,00", currency: "USD")
        XCTAssertEqual(usdCurrency.formattedNumber(from: ","), zeroUsd)
        XCTAssertEqual(usdCurrency.formattedNumber(from: "."), zeroUsd)
        // These are not technically invalid inputs but that doesnt make them `useless` tests:
        XCTAssertEqual(usdCurrency.formattedNumber(from: "0."), zeroUsd)
        XCTAssertEqual(usdCurrency.formattedNumber(from: "0,0"), zeroUsd)
        XCTAssertEqual(usdCurrency.formattedNumber(from: ",0"), zeroUsd)
        XCTAssertEqual(usdCurrency.formattedNumber(from: ".0"), zeroUsd)
    }

    private func given(amount: Decimal, currencyCode: String) {
        currentMonetaryAmount = MonetaryAmount(amount: amount, currency: currencyCode)
    }

    private func whenAmountWithoutCodeIsRetrieved() {
        resultOfOperation = currentMonetaryAmount.toAmountWithoutCode()
    }

    private func then(expectedResult: String) {
        XCTAssertEqual(resultOfOperation, expectedResult)
    }
}
