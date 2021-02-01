//
//  ManuallyEnterFeePage.swift
//  falconUITests
//
//  Created by Manu Herrera on 27/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

final class ManuallyEnterFeePage: UIElementPage<UIElements.Pages.ManuallyEnterFeePage> {

    private let button = ButtonViewPage(Root.button)
    private lazy var textField = self.textField(Root.textField)
    private lazy var warningLabel = self.label(Root.warningLabel)

    init() {
        super.init(root: Root.root)
    }

    func checkWarnings() {
        textField.typeText("0")
        XCTAssert(warningLabel.label.contains("Fee is too low."))
        clearText()

        textField.typeText("1")
        XCTAssert(warningLabel.label.contains("This transaction may take days to confirm."))
        clearText()

        textField.typeText("1000")
        XCTAssert(warningLabel.label.contains("Fee is too high."))
        clearText()
    }

    func changeFee(satsPerVByte: Decimal) {
        textField.typeText("\(satsPerVByte)")
        button.mainButtonTap()
    }

    func clearText() {
        guard let stringValue = textField.value as? String else {
            return
        }

        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        textField.typeText(deleteString)
    }

}
