//
//  ChangePasswordPrimingPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 27/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class ChangePasswordPrimingPage: UIElementPage<UIElements.Pages.ChangePasswordPriming> {

    private lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func tapContinue() -> ChangePasswordEnterCurrentPage {
        continueButton.mainButtonTap()
        return ChangePasswordEnterCurrentPage()
    }

}
