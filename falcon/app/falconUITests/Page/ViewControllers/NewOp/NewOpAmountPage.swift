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

    private lazy var input = AmountInputPage(Root.input)
    private lazy var useAllFundsButton = LinkButtonPage(Root.useAllFunds)

    init() {
        super.init(root: Root.root)
    }

    func useAllFunds() {
        useAllFundsButton.mainButtonTap()
    }

    func allFundsValue() -> String {
        return String(input.subtitle().split(separator: " ")[1])
    }

    func isCurrencyVisible() -> Bool {
        return input.isCurrencyVisible()
    }

    func clearText() {
        input.clearText()
    }

    func enter(amount: String) {
        input.enter(amount: amount)
    }

    func amount() -> String {
        return input.amount()
    }

    func tapCurrency() -> CurrencyPickerPage {
        input.tapCurrency()
        return CurrencyPickerPage()
    }

    func assertCurrencyText(_ text: String) {
        input.assertCurrencyText(text)
    }

}
