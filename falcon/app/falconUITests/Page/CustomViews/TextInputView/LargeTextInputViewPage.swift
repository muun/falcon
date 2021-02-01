//
//  LargeTextInputViewPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

final class LargeTextInputViewPage: UIElementPage<UIElements.CustomViews.LargeTextInputViewPage> {

    private lazy var topLabel = self.label(.topLabel)
    private lazy var bottomLabel = self.label(.bottomLabel)
    private lazy var mainTextView = self.textView(.textView)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func type(text: String) {
        _ = mainTextView.waitForExistence(timeout: 1)

        if !mainTextView.focused {
            mainTextView.tap()
        }

        clearText()
        mainTextView.typeText(text)
    }

    private func clearText() {
        guard let stringValue = mainTextView.value as? String,
            !stringValue.isEmpty else {
            return
        }

        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        mainTextView.typeText(deleteString)
    }

}
