//
//  XCUIElement+Extension.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 10/09/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest
import UIKit

extension XCUIElement {

    var displayed: Bool {
        guard self.exists && !frame.isEmpty else {
            return false
        }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }

    var focused: Bool {
        return (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }
}
