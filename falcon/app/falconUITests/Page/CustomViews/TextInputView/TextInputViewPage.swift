//
//  TextInputViewPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

final class TextInputViewPage: UIElementPage<UIElements.CustomViews.TextInputViewPage> {

    private lazy var topLabel = self.label(.topLabel)
    private lazy var bottomLabel = self.label(.bottomLabel)
    private var mainTextField: XCUIElement {
        let textField = self.textField(.textfield)
        if textField.exists {
            return textField
        } else {
            return self.secureTextField(.textfield)
        }
    }

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func type(text: String) {
        _ = mainTextField.waitForExistence(timeout: 1)

        let lowerRightCorner = mainTextField.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
        lowerRightCorner.tap()

        clearText()
        mainTextField.typeText(text)
    }

    func clearText() {
        guard let stringValue = mainTextField.value as? String else {
            return
        }

        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        if !mainTextField.focused {
            mainTextField.tap()
        }
        mainTextField.typeText(deleteString)
    }

    func bottomLabelTextMatches(_ value: String, in test: XCTestCase) {
        for _ in 0..<2 {
            if bottomLabel.exists && bottomLabel.label == value {
                break
            }

            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssert(bottomLabel.label == value, "bottomLabel\(bottomLabel.label) != \(value)")
    }

}
