//
//  ActivateEmergencyKitPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 14/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest

final class ActivateEmergencyKitPage: UIElementPage<UIElements.Pages.EmergencyKit.ActivatePDF> {

    private lazy var segment0 = textField(.segment0)
    private lazy var segment1 = textField(.segment1)
    private lazy var segment2 = textField(.segment2)
    private lazy var segment3 = textField(.segment3)
    private lazy var segment4 = textField(.segment4)
    private lazy var segment5 = textField(.segment5)
    private lazy var activationCodeLabel = label(Root.activationCodeLabel)

    init() {
        super.init(root: Root.root)
    }

    func segment(index: Int) -> XCUIElement {
        switch index {
        case 0: return segment0
        case 1: return segment1
        case 2: return segment2
        case 3: return segment3
        case 4: return segment4
        case 5: return segment5
        default:
            return segment0
        }
    }

    private func getCode() -> String {
        // For testing purposes the activationCodeLabel contains the actual code in the test environment only
        return activationCodeLabel.label
    }

    func tryIncorrectAndThenCorrectCode() -> FeedbackPage {
        let correctCode = getCode()
        let incorrectCode = getIncorrectCode(correctCode)

        tryIncorrectCode(incorrectCode)
        return writeCorrectCode(correctCode)
    }

    private func getIncorrectCode(_ correctCode: String) -> String {
        let randomCode = "123456"
        if correctCode != randomCode {
            return randomCode
        }

        return "123457"
    }

    func writeCorrectCode(_ code: String) -> FeedbackPage {
        clearText(codeLength: code.count)
        write(code.map({ String($0) }))
        return FeedbackPage()
    }

    func tryIncorrectCode(_ code: String) {
        clearText(codeLength: code.count)
        write(code.map({ String($0) }))
        XCTAssert(activationCodeLabel.label.contains(L10n.ActivateEmergencyKitView.s8))
    }

    private func write(_ code: [String]) {
        for i in 0..<code.count {
            let seg = segment(index: i)
            seg.doubleTap()
            if let text = seg.value as? String, text != "" {
                seg.typeText(XCUIKeyboardKey.delete.rawValue)
            }

            seg.typeText(code[i])
        }
    }

    private func clearText(codeLength: Int) {
        for i in 0..<codeLength {
            let seg = segment(index: i)
            seg.doubleTap()
            seg.typeText(XCUIKeyboardKey.delete.rawValue)
        }
    }

}
