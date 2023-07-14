//
//  ChangePasswordTests.swift
//  falconUITests
//
//  Created by Manu Herrera on 27/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest

class ChangePasswordTests: FalconUITests {

    private var homePage: HomePage!
    private var signInTests: SignInUITests! = SignInUITests()

    override func tearDown() {
        homePage = nil
        signInTests = nil

        super.tearDown()
    }

    func testChangePassword() {
        homePage = createUser()
        let (email, password, rc) = securityCenterTests.fullSecuritySetup(in: homePage)
        let newPassword = "Here is to the crazy ones"

        print("Change password via old password started")
        var settingsPage = homePage.goToSettings()
        var changePasswordPrimingPage = settingsPage.tapChangePassword()
        var changePasswordStartPage = changePasswordPrimingPage.tapContinue()
        var changePasswordEnterNewPage = changePasswordStartPage.enter(password)
        changePasswordEnterNewPage.wait(10) // Wait for auto verify email
        print("Enter new password")
        var feedbackPage = changePasswordEnterNewPage.enterNew(newPassword)
        feedbackPage.finish()
        print("Password changed")

        settingsPage.wait()
        _ = settingsPage.logout()

        print("Log in with new password started")
        signInTests.fullSignIn(email: email, password: newPassword, pin: "1111")

        let secondNewPassword = "Here is to the ones with recovery code"

        print("Change password via recovery code started")
        settingsPage = homePage.goToSettings()
        changePasswordPrimingPage = settingsPage.tapChangePassword()
        changePasswordStartPage = changePasswordPrimingPage.tapContinue()
        let changePasswordEnterRecoveryCode = changePasswordStartPage.tapForgotPassword()
        changePasswordEnterNewPage = fillRecoveryCode(rc, in: changePasswordEnterRecoveryCode)
        changePasswordEnterNewPage.wait(10) // Wait for auto verify email
        print("Enter new password")
        feedbackPage = changePasswordEnterNewPage.enterNew(secondNewPassword)
        feedbackPage.finish()
        print("Password changed")

        settingsPage.wait()
        _ = settingsPage.logout()

        print("Log in with new password started")
        signInTests.fullSignIn(email: email, password: secondNewPassword, pin: "1111")
        assert(homePage.exists())
    }

    private func fillRecoveryCode(_ code: [String], in rcPage: ChangePasswordEnterRecoveryCodePage) -> ChangePasswordEnterNewPage {

        rcPage.inputInvalidCode(realCode: code)

        _ = rcPage.touchContinueButton()
        XCTAssert(rcPage.isInvalid(), "inputing an invalid code fails")

        rcPage.set(code: code)

        let enterNewPage = rcPage.touchContinueButton()
        enterNewPage.wait()
        return enterNewPage
    }
}
