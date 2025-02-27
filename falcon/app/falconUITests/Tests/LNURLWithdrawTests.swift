//
//  LNURLWithdrawTests.swift
//  falconUITests
//
//  Created by Federico Bond on 11/05/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import XCTest
@testable import Muun

class LNURLWithdrawTests: FalconUITests {

    private var homePage: HomePage!

    override func tearDown() {
        homePage = nil

        super.tearDown()
    }

    private func tapReceiveWithLNURL() -> LNURLFirstTimePage {
        app.navigationBars.buttons.matching(identifier: "Receive with LNURL").element.tap()

        let page = LNURLFirstTimePage()
        page.wait()
        return page
    }

    func testWithdraw() {
        homePage = createUser()
        _ = homePage.tapReceive()

        let firstTimePage = tapReceiveWithLNURL()
        let scanQRPage = firstTimePage.tapContinue()
        let manuallyEnterPage = scanQRPage.enterManually()

        let qr = TestLapp.lnurlWithdraw()
        manuallyEnterPage.enterQR(qr)

        homePage.wait(15)

        waitForOperations(count: 1, home: homePage, timeout: 60)
        homePage.assert(balance: "0.00003")
    }

    func testWithdrawFail() {
        homePage = createUser()
        _ = homePage.tapReceive()

        let firstTimePage = tapReceiveWithLNURL()
        let scanQRPage = firstTimePage.tapContinue()
        let manuallyEnterPage = scanQRPage.enterManually()

        let qr = TestLapp.lnurlWithdraw(variant: "fails")
        manuallyEnterPage.enterQR(qr)

        let errorPage = LNURLWithdrawErrorPage()
        errorPage.assertUnknownError()
        _ = errorPage.backToHome()
    }

}
