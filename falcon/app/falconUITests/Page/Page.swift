//
//  Page.swift
//  falcon
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

class Page {

    let element: XCUIElement
    static let app = XCUIApplication()

    init(element: XCUIElement) {
        self.element = element
    }

    func wait(_ timeout: TimeInterval = 4) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Wait for existence of \(element.description)")
    }

    func exists(timeout: TimeInterval = 4) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }

}
