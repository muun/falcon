//
//  RecoveryCodePage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class RecoveryCodePage: UIElementPage<UIElements.Pages.RecoveryCodePage> {

    private lazy var recoveryView = RecoveryViewPage(Root.codeView)
    private lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func verify() -> PinPage {
        continueButton.mainButtonTap()

        return PinPage()
    }

    func set(code: [String]) {
        recoveryView.set(code: code)
    }

    func inputInvalidCode(realCode: [String]) {
        recoveryView.inputInvalidCode(realCode: realCode)
    }

}
