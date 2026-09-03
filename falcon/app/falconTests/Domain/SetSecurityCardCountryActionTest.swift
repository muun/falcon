//
//  SetSecurityCardCountryActionTest.swift
//  falconTests
//
//  Created by Federico Jordán on 17/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import XCTest
@testable import Muun

class SetSecurityCardCountryActionTest: XCTestCase {

    private var repository: MarketplaceSelectedCountryRepository!
    private var action: SetSecurityCardCountryAction!

    override func setUp() {
        super.setUp()
        repository = MarketplaceSelectedCountryRepository()
        action = SetSecurityCardCountryAction(
            marketplaceSelectedCountryRepository: repository
        )
    }

    func testRunStoresTheCountryInTheRepository() {
        let country = Country(code: "MX", name: "Mexico", flag: "🇲🇽")

        action.run(country)

        XCTAssertEqual(repository.fetch(), country)
    }

    func testRunOverwritesThePreviousSelection() {
        action.run(Country(code: "US", name: "United States", flag: "🇺🇸"))
        let latest = Country(code: "JP", name: "Japan", flag: "🇯🇵")

        action.run(latest)

        XCTAssertEqual(repository.fetch(), latest)
    }
}
