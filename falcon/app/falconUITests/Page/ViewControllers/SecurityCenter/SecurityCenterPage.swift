//
//  SecurityCenterPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest

final class SecurityCenterPage: UIElementPage<UIElements.Pages.SecurityCenterPage> {

    private lazy var emailSetup = otherElement(Root.emailSetup)
    private lazy var recoveryCodeSetup = otherElement(Root.recoveryCodeSetup)
    private lazy var emergencyKit = otherElement(Root.emergencyKit)
    private lazy var recoveryTool = otherElement(Root.recoveryTool)
    private lazy var exportEmergencyKitAgain = otherElement(Root.exportEmergencyKitAgainButton)

    init() {
        super.init(root: Root.root)
    }

    func goToEmailSetup() -> PrimingEmailPage {
        emailSetup.tap()
        return PrimingEmailPage()
    }

    func skipEmail() {
        // Tap the RC setup card and nothing should happen, since it should be disabled
        recoveryCodeSetup.tap()

        let primingEmail = goToEmailSetup()
        primingEmail.skipEmail()
    }

    func goToRecoveryCodeSetup() -> PrimingRecoveryCodePage {
        recoveryCodeSetup.tap()
        return PrimingRecoveryCodePage()
    }

    func goToEmergecyKit() -> EmergencyKitSlidesPage {
        emergencyKit.tap()
        return EmergencyKitSlidesPage()
    }

    func goToEmergencyKitAgain() -> EmergencyKitSlidesPage {
        exportEmergencyKitAgain.tap()
        return EmergencyKitSlidesPage()
    }

    func goToRecoveryTool() -> RecoveryToolPage {
        recoveryTool.tap()
        return RecoveryToolPage()
    }
}
