//
//  LogOutPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 11/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class LogOutPage: UIElementPage<UIElements.Pages.LogOutPage> {

    private(set) lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func tapContinueButton() -> GetStartedPage {
        continueButton.mainButtonTap()

        return GetStartedPage()
    }

}
