//
//  ConfirmRecoveryCodePage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class ConfirmRecoveryCodePage: UIElementPage<UIElements.Pages.ConfirmRecoveryCodePage> {

    private lazy var continueButton = ButtonViewPage(Root.continueButton)
    private lazy var firstCheck = CheckViewPage(Root.firstCheck)
    private lazy var secondCheck = CheckViewPage(Root.secondCheck)

    init() {
        super.init(root: Root.root)
    }

    func confirm() -> FeedbackPage {
        firstCheck.tap()
        secondCheck.tap()
        continueButton.mainButtonTap()

        return FeedbackPage()
    }

}
