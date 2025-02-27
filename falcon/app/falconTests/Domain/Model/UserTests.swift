//
//  DateTests.swift
//  falconTests
//
//  Created by Manu Herrera on 23/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest


class UserTests: MuunTestCase {

    func testSupportId() {
        var user = Factory.user(createdAt: Date(timeIntervalSinceReferenceDate: 614635838.145))

        XCTAssert(user.getSupportId() == "9294-3038")

        let dateFormatter = Formatter.iso8601
        guard let decodedDate = dateFormatter.date(from: "1995-03-18T12:30:00.45+00:00") else {
            fatalError("Error decoding ISO8601 date")
        }

        user = Factory.user(createdAt: decodedDate)
        XCTAssert(user.getSupportId() == "9552-9800")
    }

}
