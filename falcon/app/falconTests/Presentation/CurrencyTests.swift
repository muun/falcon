//
//  CurrencyTests.swift
//  falconTests
//
//  Created by Federico Jordan on 17/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import XCTest
import Libwallet

@testable import Muun

class CurrencyTests: MuunTestCase {

    private func window() -> NewopExchangeRateWindow {
        let window = NewopExchangeRateWindow()
        window.windowId = 1
        window.addRate("BTC", rate: 1)
        window.addRate("USD", rate: 0)
        window.addRate("ARS", rate: Double.nan)
        window.addRate("EUR", rate: 50_000)
        return window
    }

    func testHasValidRateRejectsZeroNaNAndMissing() {
        let window = window()
        let currencies = CurrencyHelper.allCurrencies

        XCTAssertFalse(currencies["USD"]!.hasValidRate(in: window))
        XCTAssertFalse(currencies["ARS"]!.hasValidRate(in: window))
        // NGN has no rate in the window at all
        XCTAssertFalse(currencies["NGN"]!.hasValidRate(in: window))
    }

    func testHasValidRateAcceptsPositiveRate() {
        XCTAssertTrue(CurrencyHelper.allCurrencies["EUR"]!.hasValidRate(in: window()))
    }

    func testBitcoinIsAlwaysValid() {
        // BTC's rate is structurally 1, so it must be valid even against a degraded window.
        let degraded = NewopExchangeRateWindow()
        degraded.windowId = 1
        degraded.addRate("BTC", rate: 0)

        XCTAssertTrue(CurrencyHelper.bitcoinCurrency.hasValidRate(in: degraded))
    }

    func testResolveInitialCurrencyKeepsPreferredWithUsableRate() {
        let preferred = CurrencyHelper.allCurrencies["EUR"]!
        let resolved = ReceiveInitialCurrency.resolve(
            preferred: preferred,
            default: CurrencyHelper.bitcoinCurrency,
            window: window()
        )

        XCTAssertEqual(resolved.code, preferred.code)
    }

    func testResolveInitialCurrencyFallsBackWhenPreferredRateIsUnusable() {
        // USD's rate is zero and ARS' is NaN, so a screen must not start on either — it would make
        // validityCheck surface a misleading `.tooBig`. Both fall back to the default (BTC) unit.
        for brokenCode in ["USD", "ARS"] {
            let resolved = ReceiveInitialCurrency.resolve(
                preferred: CurrencyHelper.allCurrencies[brokenCode]!,
                default: CurrencyHelper.bitcoinCurrency,
                window: window()
            )

            XCTAssertEqual(resolved.code, CurrencyHelper.bitcoinCurrency.code)
        }
    }

    func testResolveInitialCurrencyFallsBackWhenPreferredIsNil() {
        let resolved = ReceiveInitialCurrency.resolve(
            preferred: nil,
            default: CurrencyHelper.bitcoinCurrency,
            window: window()
        )

        XCTAssertEqual(resolved.code, CurrencyHelper.bitcoinCurrency.code)
    }
}
