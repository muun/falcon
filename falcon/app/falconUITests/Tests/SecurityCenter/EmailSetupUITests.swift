//
//  EmailSetupUITests.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest

class EmailSetupUITests: FalconUITests {

    func setUpEmail(in securityCenter: SecurityCenterPage) -> (email: String, password: String) {
        addSection("security center - set up email backup")

        let newRandomEmail = "\(UUID().uuidString.prefix(8))@muun.com"

        let primingEmail = securityCenter.goToEmailSetup()
        let backUpEmailPage = primingEmail.confirm()
        backUpEmailPage.type(email: newRandomEmail)

        let setUpPasswordPage = SetUpPasswordPage()
        _ = setUpPasswordPage.element.waitForExistence(timeout: 20)
        let finishSetup = setUpPasswordPage.createPassword(genericPassword)

        let feedbackPage = finishSetup.confirm()

        feedbackPage.finish() // Back to security center

        print("Email backup successful")
        return (newRandomEmail, genericPassword)
    }

    func tryEmailSetupErrors(in securityCenter: SecurityCenterPage) {
        tryEmailErrors(in: securityCenter)
        tryPasswordErrors(in: securityCenter)
    }

    private func tryEmailErrors(in securityCenter: SecurityCenterPage) {
        addSection("tryInvalidEmail")

        let primingEmail = securityCenter.goToEmailSetup()
        let backUpEmailPage = primingEmail.confirm()
        backUpEmailPage.type(email: "muun @muun.com", shouldTapContinue: false)

        // This is to wait for the label to change its text
        _ = app.wait(for: .unknown, timeout: 1)
        XCTAssert(!backUpEmailPage.buttonView.isEnabled())

        backTo(page: securityCenter)
    }

    private func tryPasswordErrors(in securityCenter: SecurityCenterPage) {
        addSection("tryInvalidPassword")

        let newRandomEmail = "\(UUID().uuidString.prefix(8))@muun.com"

        let primingEmail = securityCenter.goToEmailSetup()
        let backUpEmailPage = primingEmail.confirm()
        backUpEmailPage.type(email: newRandomEmail)

        let setUpPasswordPage = SetUpPasswordPage()
        _ = setUpPasswordPage.element.waitForExistence(timeout: 20)
        setUpPasswordPage.type(password: genericPassword)
        setUpPasswordPage.repeatPassword("holahola")

        _ = app.wait(for: .unknown, timeout: 1) // This is to wait for the label to change its text
        setUpPasswordPage.secondTextInputView.bottomLabelTextMatches(L10n.SignUpPasswordViewController.s6, in: self)
        _ = app.wait(for: .unknown, timeout: 1) // This is to wait for the label to change its text

        back()
        app.alerts[L10n.FinishEmailSetupViewController.s5].buttons[L10n.FinishEmailSetupViewController.s7].tap()
    }
}
