//
//  BitcoinCurrencyTests.swift
//  falconTests
//
//  Created by Lucas Serruya on 10/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun
import XCTest


class BitcoinCurrencyTest: XCTestCase, Resolver {
    var bitcoinCurrency = BitcoinCurrency()
    let preferences: Preferences = resolve()
    
    func test_FormatStringAsBtcFromDefaults() {
        givenBitcoinUnspecifiedUnitAndUserDefaultsBTCUnit()
        thenBitcoinCurrencyIsFormattedAsBTCUnit()
    }
    
    func test_FormatStringAsSATFromDefaults() {
        givenBitcoinBTCUnitAndUserDefaultsSATUnit()
        thenBitcoinCurrencyIsFormattedAsBTCUnit()
    }
    
    func test_FormatStringAsSATFixed() {
        givenBitcoinSATUnitAndUserDefaultsBTCUnit()
        thenBitcoinCurrencyIsFormattedAsBTCSAT()
    }
    
    func test_FormatStringAsBTCFixed() {
        givenBitcoinBTCUnitAndUserDefaultsSATUnit()
        thenBitcoinCurrencyIsFormattedAsBTCUnit()
    }
    
    func test_BitcoinBalanceThroughMonetaryAmount() {
        preferences.set(value: false, forKey: .displayBTCasSAT)
        let zeroBTC = MonetaryAmount(amount: "0", currency: "BTC")!
        XCTAssertEqual(zeroBTC.toAmountWithoutCode(), "0.00000000")
        XCTAssertEqual(zeroBTC.toAmountWithoutCode(btcCurrencyFormat: .short), "0.00")
        
        let amountInBTC = MonetaryAmount(amount: "1.80395", currency: "BTC")!
        XCTAssertEqual(amountInBTC.toAmountWithoutCode(), "1.80395000")
        XCTAssertEqual(amountInBTC.toAmountWithoutCode(btcCurrencyFormat: .short), "1.80395")
        
        let oneSatoshi =  MonetaryAmount(amount: "0.00000001", currency: "BTC")!
        XCTAssertEqual(oneSatoshi.toAmountWithoutCode(), "0.00000001")
        XCTAssertEqual(oneSatoshi.toAmountWithoutCode(btcCurrencyFormat: .short), "0.00000001")
    }
    
    func test_BalanceInSatoshisThroughMonetaryAmount() {
        preferences.set(value: true, forKey: .displayBTCasSAT)
        
        let zeroBTC = MonetaryAmount(amount: "0", currency: "BTC")!
        XCTAssertEqual(zeroBTC.toAmountWithoutCode(), "0")
        XCTAssertEqual(zeroBTC.toAmountPlusCode(), "0 SAT")
        
        let amountInBTC = MonetaryAmount(amount: "1.80395", currency: "BTC")!
        XCTAssertEqual(amountInBTC.toAmountWithoutCode(), "180,395,000")
        XCTAssertEqual(amountInBTC.toAmountPlusCode(), "180,395,000 SAT")
        
        let oneSatoshi =  MonetaryAmount(amount: "0.00000001", currency: "BTC")!
        XCTAssertEqual(oneSatoshi.toAmountWithoutCode(), "1")
        XCTAssertEqual(oneSatoshi.toAmountPlusCode(), "1 SAT")
    }
    
    private func givenBitcoinUnspecifiedUnitAndUserDefaultsBTCUnit() {
        CurrencyHelper.preferences.set(value: false, forKey: .displayBTCasSAT)
    }
    
    private func givenBitcoinUnspecifiedUnitAndUserDefaultsSATUnit() {
        CurrencyHelper.preferences.set(value: true, forKey: .displayBTCasSAT)
    }
    
    private func givenBitcoinBTCUnitAndUserDefaultsSATUnit() {
        CurrencyHelper.preferences.set(value: true, forKey: .displayBTCasSAT)
        bitcoinCurrency = BitcoinCurrency(unit: .BTC)
    }
    
    private func givenBitcoinSATUnitAndUserDefaultsBTCUnit() {
        CurrencyHelper.preferences.set(value: false, forKey: .displayBTCasSAT)
        bitcoinCurrency = BitcoinCurrency(unit: .SAT)
    }
    
    private func thenBitcoinCurrencyIsFormattedAsBTCUnit() {
        let zeroBTC = MonetaryAmount(amount: "0", currency: "BTC")!
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: zeroBTC.amount), "0.00000000")
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: zeroBTC.amount, btcCurrencyFormat: .short), "0.00")
        
        let amountInBTC = MonetaryAmount(amount: "1.80395", currency: "BTC")!
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: amountInBTC.amount), "1.80395000")
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: amountInBTC.amount, btcCurrencyFormat: .short), "1.80395")
        
        let oneSatoshi =  MonetaryAmount(amount: "0.00000001", currency: "BTC")!
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: oneSatoshi.amount), "0.00000001")
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: oneSatoshi.amount, btcCurrencyFormat: .short), "0.00000001")
    }
    
    private func thenBitcoinCurrencyIsFormattedAsBTCSAT() {
        let zeroBTC = MonetaryAmount(amount: "0", currency: "BTC")!
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: zeroBTC.amount), "0")
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: zeroBTC.amount, btcCurrencyFormat: .short), "0")
        
        let amountInBTC = MonetaryAmount(amount: "1.80395", currency: "BTC")!
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: amountInBTC.amount), "180,395,000")
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: amountInBTC.amount, btcCurrencyFormat: .short), "180,395,000")
        
        let oneSatoshi =  MonetaryAmount(amount: "0.00000001", currency: "BTC")!
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: oneSatoshi.amount), "1")
        XCTAssertEqual(bitcoinCurrency.toAmountWithoutCode(amount: oneSatoshi.amount, btcCurrencyFormat: .short), "1")
    }
}
