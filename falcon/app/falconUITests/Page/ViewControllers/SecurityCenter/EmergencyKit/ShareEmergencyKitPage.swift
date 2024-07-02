//
//  ShareEmergencyKitPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 14/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest

final class ShareEmergencyKitPage: UIElementPage<UIElements.Pages.EmergencyKit.SharePDF> {

    private lazy var saveManuallyView = otherElement(Root.saveManually)
    private lazy var confirmSave = SmallButtonViewPage(Root.confirm)

    init() {
        super.init(root: Root.root)
    }

    func savePDF() -> ActivateEmergencyKitPage {
        sleep(3) // Wait for the creation of the EK
        saveManuallyView.tap()
        confirmSave.mainButtonTap()

        // Hack to tap the copy button on the activity view controller
        XCUIApplication().cells.element(boundBy: 0).waitForExistence(timeout: 3)
        XCUIApplication().cells.element(boundBy: 0).tap()

        return ActivateEmergencyKitPage()
    }

}
