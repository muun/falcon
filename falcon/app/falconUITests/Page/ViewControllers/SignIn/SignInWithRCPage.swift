//
//  SignInWithRCPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 23/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest

final class SignInWithRCPage: UIElementPage<UIElements.Pages.SignInWithRCPage> {

    private lazy var recoveryView = RecoveryViewPage(Root.codeView)
    private lazy var errorLabel = button(.errorLabel)
    private lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func tryWrongCodeAndAssertError(realCode: [String]) {
        recoveryView.inputInvalidCode(realCode: realCode)
        continueButton.mainButtonTap()

        XCTAssert(
            Page.app.staticTexts[L10n.SignInWithRCView.s4]
                .waitForExistence(timeout: 1),
            "Error label should be displayed on invalid signature"
        )
    }

    func tryOldRecoveryCodeAndAssertError() {
        let oldRecoveryCode = ["AAAA", "AAAA", "AAAA", "AAAA", "AAAA", "AAAA", "AAAA", "AAAA"]
        recoveryView.set(code: oldRecoveryCode)
        continueButton.mainButtonTap()

        _ = errorLabel.waitForExistence(timeout: 1)
        XCTAssert(
            errorLabel.label.contains(L10n.SignInWithRCView.s6),
            "Old Recovery Code version error should be displayed on the screen"
        )
    }

    func advanceWithValidCode(_ code: [String]) -> PinPage {
        recoveryView.set(code: code)
        continueButton.mainButtonTap()

        return PinPage()
    }

}
