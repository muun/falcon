//
//  EmergencyKitSlidesPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 17/03/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class EmergencyKitSlidesPage: UIElementPage<UIElements.Pages.EmergencyKit.Slides> {

    private lazy var continueButton = ButtonViewPage(Root.continueButton)

    init() {
        super.init(root: Root.root)
    }

    func tapContinue() -> ShareEmergencyKitPage {
        while !continueButton.displayed {
            element.swipeLeft()
        }
        continueButton.mainButtonTap()
        return ShareEmergencyKitPage()
    }

}
