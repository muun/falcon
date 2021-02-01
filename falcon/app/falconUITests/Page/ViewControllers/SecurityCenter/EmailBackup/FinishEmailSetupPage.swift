//
//  FinishEmailSetupPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class FinishEmailSetupPage: UIElementPage<UIElements.Pages.FinishEmailSetupPage> {

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
