//
//  LNURLFirstTimePage.swift
//  falconUITests
//
//  Created by Federico Bond on 11/05/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation

final class LNURLFirstTimePage: UIElementPage<UIElements.Pages.LNURLFirstTimePage> {

    private lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func tapContinue() -> LNURLScanQRPage {
        continueButton.mainButtonTap()

        return LNURLScanQRPage()
    }

}
