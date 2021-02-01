//
//  SecurityCenterTests.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest

class SecurityCenterTests: FalconUITests {

    private var securityCenter: SecurityCenterPage! = SecurityCenterPage()
    private var emailSetupUITests: EmailSetupUITests! = EmailSetupUITests()
    private var recoveryCodeUITest: RecoveryCodeUITest! = RecoveryCodeUITest()
    private var emergencyKitUITest: EmergencyKitUITest! = EmergencyKitUITest()

    override func tearDown() {
        securityCenter = nil
        emailSetupUITests = nil
        recoveryCodeUITest = nil
        emergencyKitUITest = nil

        super.tearDown()
    }

    func fullSecuritySetup(in homePage: HomePage) -> (email: String, password: String, recoveryCode: [String]) {
        securityCenter = homePage.goToSecurityCenter()

        let (email, pass) = emailSetupUITests.setUpEmail(in: securityCenter)
        let rc = recoveryCodeUITest.setUpRecoveryCode(in: securityCenter)
        exportEmergencyKit()

        backTo(page: securityCenter)
        _ = securityCenter.goToHome()

        return (email, pass, rc)
    }

    // Returns the recovery code
    func skipEmailSetUpRCAndExportKeys(in homePage: HomePage) -> [String] {
        securityCenter = homePage.goToSecurityCenter()
        securityCenter.skipEmail()

        let rc = recoveryCodeUITest.setUpRecoveryCode(in: securityCenter)
        exportEmergencyKit()

        backTo(page: securityCenter)
        _ = securityCenter.goToHome()
        return rc
    }

    func setUpEmailAndPassword(in homePage: HomePage) -> (email: String, password: String) {
        securityCenter = homePage.goToSecurityCenter()
        let (email, pass) = emailSetupUITests.setUpEmail(in: securityCenter)
        backTo(page: securityCenter)
        _ = securityCenter.goToHome()

        return (email, pass)
    }

    func testEmailSetupErrors() {
        let homePage = createUser()
        let secCenter = homePage.goToSecurityCenter()
        emailSetupUITests.tryEmailSetupErrors(in: secCenter)
    }

    private func exportEmergencyKit() {
        emergencyKitUITest.exportEmergencyKit(in: securityCenter)
    }

}

