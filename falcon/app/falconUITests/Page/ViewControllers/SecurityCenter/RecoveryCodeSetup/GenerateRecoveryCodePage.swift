//
//  GenerateRecoveryCodePage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class GenerateRecoveryCodePage: UIElementPage<UIElements.Pages.GenerateRecoveryCodePage> {

    private lazy var continueButton = ButtonViewPage(Root.continueButton)
    private lazy var recoveryView = RecoveryViewPage(Root.codeView)

    init() {
        super.init(root: Root.root)
    }

    func touchContinueButton() -> VerifyRecoveryCodePage {
        continueButton.mainButtonTap()

        return VerifyRecoveryCodePage()
    }

    func recoveryCode() -> [String] {
        return [
            recoveryView.value(for: 1),
            recoveryView.value(for: 2),
            recoveryView.value(for: 3),
            recoveryView.value(for: 4),
            recoveryView.value(for: 5),
            recoveryView.value(for: 6),
            recoveryView.value(for: 7),
            recoveryView.value(for: 8)
        ]
    }

}
