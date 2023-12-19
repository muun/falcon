//
//  PinUITest.swift
//  falconUITests
//
//  Created by Lucas Serruya on 02/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import XCTest

class PinUITest: FalconUITests {

    func test_recoverableUser() {
        (_, _, _) = createRecoverableUser()

        addSection("Ten seconds rule")

        stayTwelveSecondInBackgroundAndOpenAppAgain()
        assertPinScreenIsBeignDisplayed()

        addSection("Attempts left displayed after relaunch")

        insertWrognPin()
        relaunchApp()
        assertNumberOfAttemptsLeftIsBeingDisplayed()

        addSection("Do not display pin screen if user stays less than 10 seconds in background")

        insertPin()
        stayTwoSecondInBackgroundAndOpenAppAgain()
        assertPinScreenIsNotBeignDisplayed()

        addSection("Do not display attempts left on relaunch and has all of them")

        relaunchApp()
        assertNumberOfAttemptsLeftIsNotBeingDisplayed()

        addSection("Attempts left inmeadiatly displayed after wrong attempt")

        insertWrognPin()
        assertNumberOfAttemptsLeftIsBeingDisplayed()
    }

    func test_unrecoverableUser() {
        addSection("Invalid pin instead of attempts left for unrecoverable users")
        _ = createWalletTests.createWallet()
        relaunchApp()

        insertWrognPin()

        assertNumberOfAttemptsLeftIsNotBeingDisplayed()
        assertInvalidPinIsBeingDisplayed()

        addSection("Invalid pin is not visible after realaunch")
        relaunchApp()
        assertInvalidPinIsNotBeingDisplayed()
    }
}

private extension PinUITest {
    func relaunchApp() {
        XCUIApplication().terminate()
        XCUIApplication().activate()
    }

    func insertWrognPin() {
        let pinPage = PinPage()
        pinPage.enterPin("9999")
    }

    func insertPin() {
        let pinPage = PinPage()
        pinPage.enterPin("1111")
    }

    func stayTwelveSecondInBackgroundAndOpenAppAgain() {
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        Thread.sleep(forTimeInterval: 12)
        XCUIApplication().activate()
    }

    func stayTwoSecondInBackgroundAndOpenAppAgain() {
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        Thread.sleep(forTimeInterval: 2)
        XCUIApplication().activate()
    }

    func assertNumberOfAttemptsLeftIsBeingDisplayed() {
        let pinPage = PinPage()
        XCTAssert(
            pinPage.isDisplayingAttemptsLeftHint(numberOfAttempts: 2),
            "Pin screen is not displaying attempts left after app launched"
        )
    }

    func assertInvalidPinIsBeingDisplayed() {
        let pinPage = PinPage()
        XCTAssert(
            pinPage.isDisplayingInvalidPinHint(),
            "Invalid Pin hint is not being displayed"
        )
    }

    func assertInvalidPinIsNotBeingDisplayed() {
        let pinPage = PinPage()
        XCTAssertFalse(
            pinPage.isDisplayingInvalidPinHint(),
            "Invalid Pin hint is not being displayed"
        )
    }

    func assertNumberOfAttemptsLeftIsNotBeingDisplayed() {
        let pinPage = PinPage()
        for attempts in 1...3 {
            XCTAssertFalse(
                pinPage.isDisplayingAttemptsLeftHint(numberOfAttempts: attempts),
                "Pin screen is displaying attempts left after app launched"
            )
        }
    }

    func assertPinScreenIsBeignDisplayed() {
        let pinPage = PinPage()
        XCTAssert(
            pinPage.isInLockModeAndPresent(),
            "PinScreen not presented"
        )
    }

    func assertPinScreenIsNotBeignDisplayed() {
        let pinPage = PinPage()
        XCTAssertFalse(
            pinPage.isInLockModeAndPresent(),
            "PinScreen Present"
        )
    }
}
