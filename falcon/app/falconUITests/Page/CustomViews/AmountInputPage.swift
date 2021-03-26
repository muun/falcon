//
//  AmountInputPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 08/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import XCTest

final class AmountInputPage: UIElementPage<UIElements.CustomViews.AmountInput> {

    private lazy var input = self.textField(.input)
    private lazy var currency = self.button(.currency)
    private lazy var subtitleLabel = self.label(Root.subtitle)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func subtitle() -> String {
        return subtitleLabel.label
    }

    func isCurrencyVisible() -> Bool {
        return currency.isHittable
    }

    func clearText() {
        guard let stringValue = input.value as? String else {
            return
        }

        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        input.typeText(deleteString)
    }

    func enter(amount: String) {
        clearText()
        input.typeText(amount)
    }

    func amount() -> String {
        // swiftlint:disable force_cast
        return input.value as! String
        // swiftlint:enable force_cast
    }

    func tapCurrency() {
        currency.tap()
    }

    func assertCurrencyText(_ text: String) {
        XCTAssert(currency.label.contains(text))
    }

}
