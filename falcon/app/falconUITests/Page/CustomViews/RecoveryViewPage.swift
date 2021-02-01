//
//  RecoveryCodePage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

final class RecoveryViewPage: UIElementPage<UIElements.CustomViews.RecoveryViewPage> {

    private lazy var segment1 = textField(.segment1)
    private lazy var segment2 = textField(.segment2)
    private lazy var segment3 = textField(.segment3)
    private lazy var segment4 = textField(.segment4)
    private lazy var segment5 = textField(.segment5)
    private lazy var segment6 = textField(.segment6)
    private lazy var segment7 = textField(.segment7)
    private lazy var segment8 = textField(.segment8)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    private func element(for number: Int) -> XCUIElement {
        switch number {
        case 1:
            return segment1
        case 2:
            return segment2
        case 3:
            return segment3
        case 4:
            return segment4
        case 5:
            return segment5
        case 6:
            return segment6
        case 7:
            return segment7
        case 8:
            return segment8
        default:
            fatalError()
        }
    }

    func value(for segment: Int) -> String {
        // swiftlint:disable force_cast
        let value = element(for: segment).value as! String
        // swiftlint:enable force_cast

        if value == "XXXX" {
            return ""
        } else {
            return value
        }
    }

    private func set(_ value: String, for segment: Int) {
        let segmentElement = element(for: segment)
        if !segmentElement.focused {
            segmentElement.tap()
        }

        for _ in 0..<4 {
            // Check that text isn't empty and isn't the placeholder
            if let text = segmentElement.value as? String, text != "", text != "XXXX" {
                segmentElement.typeText(XCUIKeyboardKey.delete.rawValue)
            }
        }

        return segmentElement.typeText(value)
    }

    func inputInvalidCode(realCode: [String]) {
        for (i, segment) in realCode.enumerated() {
            if value(for: i + 1).isEmpty {
                if i == 0 {
                    // We need the first segment to start with the right character
                    set(String(segment), for: i + 1)
                } else {
                    set(String(segment.reversed()), for: i + 1)
                }
            }
        }
    }

    func set(code: [String]) {
        for (i, segment) in code.enumerated() {
            set(segment, for: i + 1)
        }
    }
}
