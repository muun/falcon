//
//  MarketplaceSelectedCountryRepositoryTest.swift
//  falconTests
//
//  Created by Federico Jordán on 06/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import XCTest
@testable import Muun

class MarketplaceSelectedCountryRepositoryTest: XCTestCase {

    private var repository: MarketplaceSelectedCountryRepository!

    override func setUp() {
        super.setUp()
        repository = MarketplaceSelectedCountryRepository()
    }

    func testFetchReturnsDefaultWhenNothingStored() {
        XCTAssertEqual(repository.fetch(), .default)
    }

    func testSetThenFetchReturnsStoredCountry() {
        let country = Country(code: "BR", name: "Brazil", flag: "🇧🇷")

        repository.set(country)

        XCTAssertEqual(repository.fetch(), country)
    }

    func testSetOverwritesThePreviousCountry() {
        repository.set(Country(code: "US", name: "United States", flag: "🇺🇸"))
        let latest = Country(code: "JP", name: "Japan", flag: "🇯🇵")

        repository.set(latest)

        XCTAssertEqual(repository.fetch(), latest)
    }
}
