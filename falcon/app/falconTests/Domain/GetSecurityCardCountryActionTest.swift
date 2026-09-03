//
//  GetSecurityCardCountryActionTest.swift
//  falconTests
//
//  Created by Federico Jordán on 06/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import XCTest
@testable import Muun

class GetSecurityCardCountryActionTest: XCTestCase {

    private var repository: MarketplaceSelectedCountryRepository!
    private var action: GetSecurityCardCountryAction!

    override func setUp() {
        super.setUp()
        repository = MarketplaceSelectedCountryRepository()
        action = GetSecurityCardCountryAction(
            marketplaceSelectedCountryRepository: repository
        )
    }

    func testReturnsDefaultWhenNoCountryStored() {
        let country = action.run()

        XCTAssertEqual(country, .default)
    }

    func testReturnsTheCountryStoredInTheRepository() {
        let stored = Country(code: "MX", name: "Mexico", flag: "🇲🇽")
        repository.set(stored)

        let country = action.run()

        XCTAssertEqual(country, stored)
    }
}
