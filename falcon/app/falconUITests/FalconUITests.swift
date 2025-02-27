//
//  FalconUITests.swift
//  FalconUITests
//
//  Created by Manu Herrera on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest
@testable import Muun

class FalconUITests: XCTestCase {

    let app = XCUIApplication()
    var createWalletTests: CreateWalletTests!
    var securityCenterTests: SecurityCenterTests!

    let genericPassword = "MuunRulesTheWorld"
    let genericPin = "1111"

    var isNotificationsPermissionAvailable: Bool?

    override func setUp() {
        continueAfterFailure = false
        createWalletTests = CreateWalletTests()
        securityCenterTests = SecurityCenterTests()

        app.launchArguments = ["testMode"]
        app.launch()

        // Clear the clipboard
        UIPasteboard.general.items = []
    }

    func back() {
        if app.navigationBars.count == 0 {
            app.buttons.matching(identifier: "nav_back").element.tap()
        } else {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    func addSection(_ name: String) {
        print(name)
        XCTContext.runActivity(named: name, block: { _ in })
    }

    func createUser(utxos: [Decimal] = []) -> HomePage {
        let homePage = createWalletTests.createWallet()
        if !utxos.isEmpty {
            let address = homePage.getAddress()
            backTo(page: homePage)
            homePage.wait()
            sendTo(address, in: homePage, utxos: utxos)
        }

        return homePage
    }

    func createRecoverableUser(utxos: [Decimal] = []) -> (homePage: HomePage,
                                                          email: String,
                                                          password: String,
                                                          recoveryCode: [String]) {
        let homePage = createUser(utxos: utxos)

        let (email, password, rc) = securityCenterTests.fullSecuritySetup(in: homePage)

        return (homePage, email, password, rc)
    }

    func createRecoverableUser(utxos: [Decimal] = []) -> (homePage: HomePage,
                                                          email: String,
                                                          password: String) {
        let homePage = createUser(utxos: utxos)

        let (email, password) = securityCenterTests.setUpEmailAndPassword(in: homePage)

        return (homePage, email, password)
    }

    private func sendTo(_ address: String, in homePage: HomePage, utxos: [Decimal]) {

        XCTAssert(!address.isEmpty, "expected address to be non-empty")

        _ = homePage.openOperationsList()
        // Pre generate to make sure regtest has funds to send
        TestLapp.generate(blocks: 10)
        for utxo in utxos {
            TestLapp.send(to: address, amount: utxo)
        }

        // Wait for ops to come in from firebase
        _ = Page.app.staticTexts[L10n.OperationFormatter.s2].waitForExistence(timeout: 60)
        XCTAssert(Page.app.staticTexts[L10n.OperationFormatter.s2].exists, "failed to receive ops from firebase")

        // Add a delay to let the app process all the new operation notifications
        sleep(2)

        backTo(page: homePage)
    }

    func backTo(page: Page) {
        while !page.exists() {
            back()
        }
    }

    func waitForOperations(count: Int, home: HomePage, timeout: TimeInterval = 30) {
        let transactionsPage = home.openOperationsList()

        waitUntil(condition: { () -> Bool in
            transactionsPage.operationCells.count == count
        }, timeout: timeout, description: "waiting for \(count) operations")

        backTo(page: home)
    }

    func waitUntil(condition: @escaping () -> Bool, timeout: TimeInterval = 30, description: String) {
        let start = Date()

        print(description)
        while Date().timeIntervalSince(start) < timeout {
            Thread.sleep(forTimeInterval: 0.05)
            if condition() {
                return
            }
        }

        XCTFail("waited for condition \(description)")
    }

    func allowNotifications(_ enabled: Bool = true) {
        addUIInterruptionMonitor(withDescription: "Notification Dialog") { (alert) -> Bool in
            self.isNotificationsPermissionAvailable = enabled
            let alertButton = enabled
                ? alert.buttons["Allow"]
                : alert.buttons["Don't Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            self.app.tap()
            return false
        }

        if isNotificationsPermissionAvailable == nil {
            app.tap()
        }
    }

    override func tearDown() {
        super.tearDown()

        securityCenterTests = nil
    }
}
