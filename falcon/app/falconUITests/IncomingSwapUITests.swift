//
//  IncomingSwapUITests.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 09/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest

class IncomingSwapUITests: FalconUITests {

    var securityCenterTests: SecurityCenterTests!

    override func setUp() {
        super.setUp()

        securityCenterTests = SecurityCenterTests()
    }

    public func testChangingInvoice() {
        // Empty wallet, crazy stuff!
        let homePage = createUser()

        // clear the mempool
        generate(blocks: 1)

        let receivePage = homePage.tapReceive()

        let firstInvoice = receivePage.invoice()

        // Now ask for an address, then an invoice again and the invoice should change
        _ = receivePage.address()
        let secondInvoice = receivePage.invoice()
        XCTAssertNotEqual(firstInvoice, secondInvoice)

        var paid = false
        payWithLapp(invoice: secondInvoice, amountInSats: 100) {
            paid = true
        }

        // Wait until we receive the payment
        waitUntil(condition: { () -> Bool in
            mempoolCount() == 1
        }, timeout: 60, description: "waiting for lightning payment to show up in mempool")

        // Receiving a payment should change the QR too
        waitUntil(condition: {
                    receivePage.invoice() != secondInvoice
        }, timeout: 60, description: "wait for the invoice to change after a payment arrives")

        waitUntil(condition: { mempoolCount() == 2 }, timeout: 60, description: "waiting for fulfillment to be broadcast")
        assertPaid(isPaid: { paid })
    }

    public func testIncomingSwap() {
        addSection("setup user")

        // Empty wallet, crazy stuff!
        let homePage = createUser()

        // Clear the mempool
        generate(blocks: 1)

        addSection("small amount incoming swap")
        var expectedBalance = formatBTCAmount(0.00000100, format: .short)
        receiveZeroConfSpend(homePage, amount: 100, balance: expectedBalance, operations: 1)

        addSection("big amount incoming swap")
        expectedBalance = formatBTCAmount(0.00100100, format: .short)
        receiveZeroConfSpend(homePage, amount: 100_000, balance: expectedBalance, operations: 2)

        addSection("big amount without turbo channels")
        disableTurboChannels(homePage)
        expectedBalance = formatBTCAmount(0.00200100, format: .short)
        receiveOneConfSpend(homePage, amount: 100_000, balance: expectedBalance, operations: 3)

        addSection("big amount premature spend")
        expectedBalance = formatBTCAmount(0.00300100, format: .short)
        let isPaid = receive(homePage, amount: 100_000, balance: expectedBalance, operations: 4, oneConf: true)

        sweepWallet(homePage, amount: 0.00299577, fee: 0.00000523)
        waitUntil(condition: isPaid, timeout: 60, description: "waiting until LND sees last payment")
    }

    public func testFullDebt() {
        addSection("setup user")

        // Empty wallet, crazy stuff!
        let homePage = createUser()

        // Clear the mempool
        generate(blocks: 1)

        addSection("small amount incoming swap with TX to accumulate debt")
        var expectedBalance = formatBTCAmount(0.00000100, format: .short)
        receiveZeroConfSpend(homePage, amount: 100, balance: expectedBalance, operations: 1)

        // Settle the debt we just acquired
        generate(blocks: 6)
        sleep(5) // Give syncer time to process the block

        addSection("small amount incoming swap without TX")
        expectedBalance = formatBTCAmount(0.00000200, format: .short)
        receiveFullDebt(homePage, amount: 100, balance: expectedBalance, operations: 2)

        addSection("small amount incoming swap without TX without turbo")
        expectedBalance = formatBTCAmount(0.00000300, format: .short)
        disableTurboChannels(homePage)
        receiveFullDebt(homePage, amount: 100, balance: expectedBalance, operations: 3)

        addSection("big amount incoming swap to enable sweeping")
        expectedBalance = formatBTCAmount(0.00100300, format: .short)
        enableTurboChannels(homePage)
        receiveZeroConfSpend(homePage, amount: 100_000, balance: expectedBalance, operations: 4)

        sweepWallet(homePage, amount: 0.00099994, fee: 0.00000306)
    }

    public func testLogoutConditions() {

        addSection("setup user")

        // Empty wallet, crazy stuff!
        let homePage = createUser()
        // Make the user recoverable by setting email and password
        _ = securityCenterTests.setUpEmailAndPassword(in: homePage)

        disableTurboChannels(homePage)

        // Clear the mempool
        generate(blocks: 1)

        addSection("big amount incoming swap")
        let expectedBalance = formatBTCAmount(0.00100000, format: .short)
        let isPaid = receive(homePage, amount: 100_000, balance: expectedBalance, operations: 1, oneConf: true)

        addSection("cant logout")
        let settingsPage = homePage.goToSettings()
        settingsPage.assertLogoutIsBlocked()

        // Go back so we process notifications in the home
        _ = settingsPage.goToHome()

        addSection("confirm swap and logout")
        generate(blocks: 1)
        waitUntil(condition: { mempoolCount() == 1 }, timeout: 60, description: "waiting for fulfillment to be broadcast")

        assertPaid(isPaid: isPaid)

        // Go to settings and log out
        let getStarted = homePage.goToSettings().logout()
        getStarted.wait()
    }

    typealias isPaid = () -> Bool

    fileprivate func receive(_ homePage: HomePage,
                             amount: Int64,
                             balance: String,
                             operations: Int,
                             oneConf: Bool,
                             fullDebt: Bool = false) -> isPaid {

        let invoice = homePage.getInvoice()
        back()

        var paid = false
        payWithLapp(invoice: invoice, amountInSats: amount) {
            paid = true
        }

        waitForOperations(count: operations, home: homePage, timeout: 60)
        homePage.assert(balance: balance)

        if fullDebt {
            waitUntil(condition: { paid }, timeout: 60, description: "waiting for LND to see payment for full debt")
            XCTAssertEqual(0, mempoolCount())
        } else if oneConf {
            // Wait a bit to ensure the node has seen updates
            sleep(10)

            XCTAssertFalse(paid, "LND shouldn't see payment yet")
            XCTAssertEqual(1, mempoolCount())
        } else {
            waitUntil(condition: { mempoolCount() == 2 }, timeout: 60, description: "waiting for the fulfillment to be broadcast")
            waitUntil(condition: { paid }, timeout: 60, description: "waiting for LND to see payment for zero conf")
        }

        return { paid }
    }

    fileprivate func assertPaid(isPaid: @escaping IncomingSwapUITests.isPaid) {
        // Wait for LND to see the payment
        waitUntil(condition: isPaid, timeout: 60, description: "waiting for LND to see payment")

        // Settle the swap
        generate(blocks: 6)

        // Give the app time to process all the notifications
        sleep(10)
    }

    fileprivate func receiveFullDebt(_ homePage: HomePage,
                                     amount: Int64,
                                     balance: String,
                                     operations: Int) {
        let isPaid = receive(homePage,
                             amount: amount,
                             balance: balance,
                             operations: operations,
                             oneConf: false,
                             fullDebt: true)

        assertPaid(isPaid: isPaid)
    }

    fileprivate func receiveZeroConfSpend(_ homePage: HomePage,
                                          amount: Int64,
                                          balance: String,
                                          operations: Int) {
        let isPaid = receive(homePage, amount: amount, balance: balance, operations: operations, oneConf: false)

        assertPaid(isPaid: isPaid)
    }

    fileprivate func receiveOneConfSpend(_ homePage: HomePage,
                                         amount: Int64,
                                         balance: String,
                                         operations: Int) {
        let isPaid = receive(homePage, amount: amount, balance: balance, operations: operations, oneConf: true)

        generate(blocks: 1)
        waitUntil(condition: { mempoolCount() == 1 }, timeout: 60, description: "waiting for fulfillment to be broadcast")

        assertPaid(isPaid: isPaid)
    }

    fileprivate func sweepWallet(_ homePage: HomePage,
                                 amount expectedAmount: Decimal,
                                 fee expectedFee: Decimal) {

        let address = getBech32Address()
        let newOpPage = homePage.enter(address: address)

        let amountPage = NewOpAmountPage()
        amountPage.wait()
        _ = amountPage.tapCurrency()
            .selectCurrency(index: 0)
        amountPage.assertCurrencyText("BTC")

        amountPage.useAllFunds()

        let descriptionPage = NewOpDescriptionPage()
        descriptionPage.wait()
        descriptionPage.enter(description: "All funds baby")
        newOpPage.touchContinueButton()

        newOpPage.waitForConfirm()

        // Use 1 sat/vbyte to make amounts predictable
        newOpPage.touchEditFee()
            .tapEnterFeeManually()
            .changeFee(satsPerVByte: 1)
        newOpPage.waitForConfirm()

        let (_, amount, fee, _) = newOpPage.filledData()
        XCTAssertEqual(formatBTCAmount(expectedAmount), amount)
        XCTAssertEqual(formatBTCAmount(expectedFee), fee)

        newOpPage.touchContinueButton()

        homePage.wait(10)
        XCTAssert(homePage.exists())

        homePage.assert(balance: "0.00")
    }

    fileprivate func disableTurboChannels(_ homePage: HomePage) {
        let lightningNetworkPage = homePage.goToSettings().tapLightningNetwork()

        lightningNetworkPage.wait()
        lightningNetworkPage.tapTurboChannels()

        Page.app.alerts[L10n.LightningNetworkSettings.confirmTitle]
            .buttons[L10n.LightningNetworkSettings.disable]
            .tap()

        back()
        _ = homePage.goToHome()
    }

    fileprivate func enableTurboChannels(_ homePage: HomePage) {
        let lightningNetworkPage = homePage.goToSettings().tapLightningNetwork()

        lightningNetworkPage.wait()
        lightningNetworkPage.tapTurboChannels()

        back()
        _ = homePage.goToHome()
    }

}
