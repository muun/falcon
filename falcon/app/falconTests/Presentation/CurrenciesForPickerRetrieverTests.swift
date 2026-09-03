//
//  CurrenciesForPickerRetrieverTests.swift
//  falconTests
//
//  Created by Federico Jordan on 11/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import XCTest
import Libwallet

@testable import Muun

class CurrenciesForPickerRetrieverTests: MuunTestCase {

    func testSettingsPickerFiltersCurrenciesWithInvalidRates() {
        setupBasicData()

        let window = NewopExchangeRateWindow()
        window.windowId = 1
        window.addRate("BTC", rate: 1)
        window.addRate("USD", rate: 0)
        window.addRate("ARS", rate: Double.nan)
        window.addRate("NGN", rate: 0)
        window.addRate("EUR", rate: 50_000)

        let retriever = InMemoryCurrenciesForPickerRetriever.createForSettings(
            userSelector: resolve(),
            exchangeRateWindow: window
        )

        let mostUsedCodes = retriever.executeForMostUsed().map { $0.code }
        let allCodes = retriever.executeForDisplayable().map { $0.code }

        XCTAssertFalse(mostUsedCodes.contains("USD"))
        XCTAssertFalse(allCodes.contains("USD"))
        XCTAssertFalse(allCodes.contains("ARS"))
        XCTAssertFalse(allCodes.contains("NGN"))
        // AUD has no rate in the window at all, so it must not be offered either.
        XCTAssertFalse(allCodes.contains("AUD"))
        XCTAssertTrue(mostUsedCodes.contains("BTC"))
        XCTAssertTrue(mostUsedCodes.contains("EUR"))
        XCTAssertTrue(allCodes.contains("EUR"))
    }

    func testContextualPickerKeepsBitcoinUnitsAndFiltersInvalidRates() {
        setupBasicData()

        let window = NewopExchangeRateWindow()
        window.windowId = 1
        window.addRate("BTC", rate: 1)
        window.addRate("USD", rate: 0)
        window.addRate("ARS", rate: Double.nan)
        window.addRate("NGN", rate: 0)
        window.addRate("EUR", rate: 50_000)

        let retriever = InMemoryCurrenciesForPickerRetriever.createForContextualCurrencySelection(
            userSelector: resolve(),
            exchangeRateWindow: window
        )

        let mostUsed = retriever.executeForMostUsed()
        let mostUsedCodes = mostUsed.map { $0.code }
        let allCodes = retriever.executeForDisplayable().map { $0.code }

        XCTAssertFalse(mostUsedCodes.contains("USD"))
        XCTAssertFalse(allCodes.contains("USD"))
        XCTAssertFalse(allCodes.contains("ARS"))
        XCTAssertFalse(allCodes.contains("NGN"))
        // AUD has no rate in the window at all, so it must not be offered either.
        XCTAssertFalse(allCodes.contains("AUD"))
        XCTAssertTrue(mostUsedCodes.contains("EUR"))
        XCTAssertTrue(allCodes.contains("EUR"))
        // The contextual picker additionally offers both bitcoin units.
        XCTAssertTrue(mostUsed.contains { ($0 as? BitcoinCurrency)?.unit == .BTC })
        XCTAssertTrue(mostUsed.contains { ($0 as? BitcoinCurrency)?.unit == .SAT })
    }
}
