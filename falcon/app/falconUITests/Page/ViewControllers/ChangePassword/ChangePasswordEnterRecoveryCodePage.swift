//
//  ChangePasswordEnterRecoveryCodePage.swift
//  falconUITests
//
//  Created by Manu Herrera on 04/08/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class ChangePasswordEnterRecoveryCodePage: UIElementPage<UIElements.Pages.ChangePasswordEnterRecoveryCode> {

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

    func touchContinueButton() -> ChangePasswordEnterNewPage {
        continueButton.mainButtonTap()

        return ChangePasswordEnterNewPage()
    }

}
