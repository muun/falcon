//
//  CreateWalletTests.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest

class CreateWalletTests: FalconUITests {

    private var getStartedPage: GetStartedPage!
    private var pinPage: PinPage!
    private var homePage: HomePage!

    override func tearDown() {
        getStartedPage = nil
        pinPage = nil
        homePage = nil

        super.tearDown()
    }

    func createWallet() -> HomePage {
        addSection("create new user")

        getStartedPage = GetStartedPage()
        _ = getStartedPage.createWalletButton.element.waitForExistence(timeout: 10)

        addSection("create pin")
        pinPage = getStartedPage.touchCreateWallet()
        homePage = pinPage.createPinAndAdvance(genericPin)

        print("User created")

        homePage.dismissPopUp()
        return homePage
    }

    func testInvalidPin() {
        addSection("errors on create wallet")

        getStartedPage = GetStartedPage()
        _ = getStartedPage.createWalletButton.element.waitForExistence(timeout: 10)

        pinPage = getStartedPage.touchCreateWallet()
        pinPage.enterPin(genericPin)

        // Give the next pin page time to appear
        Thread.sleep(forTimeInterval: 1)
        
        pinPage.enterPin("9999")
        XCTAssert(pinPage.hintLabel.label == L10n.PinViewController.s6)
    }

}
