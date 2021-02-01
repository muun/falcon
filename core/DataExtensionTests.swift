//
//  DataExtensionTests.swift
//  core.root-all-notifications-Unit-Tests
//
//  Created by Federico Bond on 12/01/2021.
//

import XCTest

class DataExtensionTests: XCTestCase {

    func testToHexString() {
        let data = Data(hex: "001234567890abcdef")
        XCTAssertEqual(data.toHexString(), "001234567890abcdef")
    }

}
