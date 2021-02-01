//
//  VerifyRecoveryCodePage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class VerifyRecoveryCodePage: UIElementPage<UIElements.Pages.VerifyRecoveryCodePage> {

    private lazy var recoveryView = RecoveryViewPage(Root.codeView)
    private lazy var errorLabel = label(.errorLabel)
    private lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func set(code: [String]) {
        recoveryView.set(code: code)
    }

    func inputInvalidCode(realCode: [String]) {
        recoveryView.inputInvalidCode(realCode: realCode)
    }

    func isInvalid() -> Bool {
        return errorLabel.waitForExistence(timeout: 1)
    }

    func touchContinueButton() -> ConfirmRecoveryCodePage {
        continueButton.mainButtonTap()

        return ConfirmRecoveryCodePage()
    }

}
