//
//  NewOpAmountPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

final class NewOpAmountPage: UIElementPage<UIElements.Pages.NewOp.AmountView> {

    private lazy var input = self.textField(.input)
    private lazy var currency = self.button(.currency)
    private lazy var useAllFundsButton = LinkButtonPage(Root.useAllFunds)
    private lazy var allFundsLabel = self.label(Root.allFunds)

    init() {
        super.init(root: Root.root)
    }

    func useAllFunds() {
        useAllFundsButton.mainButtonTap()
    }

    func allFundsValue() -> String {
        return String(allFundsLabel.label.split(separator: " ")[1])
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

    func tapCurrency() -> CurrencyPickerPage {
        currency.tap()
        return CurrencyPickerPage()
    }

    func assertCurrencyText(_ text: String) {
        XCTAssert(currency.label.contains(text))
    }

}
