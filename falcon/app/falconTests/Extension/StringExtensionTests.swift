//
//  StringExtensionTests.swift
//  falconTests
//
//  Created by Federico Bond on 19/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import XCTest

@testable import falcon

class StringExtensionTests: XCTestCase {

    func testSetBold() {
        "foobar".attributedForDescription()
            .set(bold: "foo", color: UIColor.red)
    }

    func testSetBoldWorksWithEmptyString() {
        "".attributedForDescription(alignment: .center)
            .set(bold: "", color: UIColor.red)
    }

}
