//
//  UIElementPage.swift
//  falcon
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

class UIElementPage<T: UIElement>: Page {

    typealias Root = T

    override init(element: XCUIElement) {
        super.init(element: element)
    }

    init(root: UIElement) {
        super.init(element: Page.app.otherElements[root.accessibilityIdentifier])
    }

    func label(_ element: T) -> XCUIElement {
        return self.element.staticTexts[element.accessibilityIdentifier]
    }

    func textField(_ element: T) -> XCUIElement {
        return self.element.textFields[element.accessibilityIdentifier]
    }

    func secureTextField(_ element: T) -> XCUIElement {
        return self.element.secureTextFields[element.accessibilityIdentifier]
    }

    func textView(_ element: T) -> XCUIElement {
        return self.element.textViews[element.accessibilityIdentifier]
    }

    func staticText(_ element: T) -> XCUIElement {
        return self.element.staticTexts[element.accessibilityIdentifier]
    }

    func button(_ element: T) -> XCUIElement {
        return self.element.buttons[element.accessibilityIdentifier]
    }

    func image(_ element: T) -> XCUIElement {
        return self.element.images[element.accessibilityIdentifier]
    }

    func table(_ element: T) -> XCUIElement {
        return self.element.tables[element.accessibilityIdentifier]
    }

    func collection(_ element: T) -> XCUIElement {
        return self.element.collectionViews[element.accessibilityIdentifier]
    }

    func otherElement(_ element: T) -> XCUIElement {
        return self.element.otherElements[element.accessibilityIdentifier]
    }

    func scrollView(_ element: T) -> XCUIElement {
        return self.element.scrollViews[element.accessibilityIdentifier]
    }

    func segmentedControl(_ element: T) -> XCUIElement {
        return self.element.segmentedControls[element.accessibilityIdentifier]
    }

    func switchControl(_ element: T) -> XCUIElement {
        return self.element.switches[element.accessibilityIdentifier]
    }

    var displayed: Bool {
        return element.displayed
    }

    func failureMessage(expected: String, actual: String) -> String {
        return "Expected: \(expected) --- Actual: \(actual)"
    }
    
    func goToHome() -> HomePage {
        XCUIApplication().buttons[L10n.AppDelegate.walletTab].tap()
        return HomePage()
    }

    func goToSettings() -> SettingsPage {
        XCUIApplication().buttons[L10n.AppDelegate.settingsTab].tap()
        return SettingsPage()
    }

    func goToSecurityCenter() -> SecurityCenterPage {
        XCUIApplication().buttons[L10n.AppDelegate.securityTab].tap()
        return SecurityCenterPage()
    }

}
