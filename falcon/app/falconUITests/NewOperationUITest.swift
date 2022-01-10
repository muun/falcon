//
//  NewOperationUITest.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

// This needs to be named diff than description because it's also a method in the test class
private let descriptionText = "Test test are tests"
private let amount = "12.12"

enum BTCCurrencyFormat {
    case long // Always uses 8 decimals
    case short // Uses at least 2 decimals and up to 8.

    func minimumFractionDigits() -> Int {
        switch self {
        case .long: return 8
        case .short: return 2
        }
    }
}

func formatBTCAmount(_ amount: Decimal, format: BTCCurrencyFormat = .long) -> String {

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 8
    formatter.minimumFractionDigits = format.minimumFractionDigits()

    return formatter.string(for: amount)!
}

class NewOperationUITest: FalconUITests {

    func testPay() {
        addSection("setup")

        let homePage = setupUser()
        let address = homePage.getAddress()
        back()
        let mempoolStartingSize = mempoolCount()

        // Enter a valid address
        let newOpPage = homePage.enter(address: address)
        let amountPage = NewOpAmountPage()
        let descriptionPage = NewOpDescriptionPage()

        addSection("pay to address - amount")
        assertAmountPage(amountPage, newOpPage)

        amountPage.useAllFunds()
        back()
        sleep(1)
        assertEmptyAmount(amountPage, newOpPage)
        assertLargeAmount(amountPage, newOpPage)

        // Enter a small amount and keep going
        amountPage.enter(amount: amount)
        newOpPage.touchContinueButton()

        addSection("pay to address - description")

        enterDescription(newOpPage, descriptionPage)

        addSection("pay to address - back testing")

        assertConfirm(to: address, amount: amount, descriptionText: descriptionText, in: newOpPage)
        assertDescriptionAfterBack(descriptionPage, newOpPage)
        assertAmountAfterBack(amountPage, newOpPage)

        // Submit the amount
        newOpPage.touchContinueButton()
        enterDescription(newOpPage, descriptionPage)

        addSection("pay to address - edit fee")
        newOpPage.selectMediumFee()

        addSection("pay to address - confirm")

        assertConfirm(to: address, amount: amount, descriptionText: descriptionText, in: newOpPage)
        assertPay(newOpPage, homePage)

        let transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: mempoolStartingSize + 1)
        XCTAssertEqual(mempoolCount(), mempoolStartingSize + 1, "We must have 1 new unconfirmed TXs")
    }

    func testUris() {
        let homePage = setupUser()
        let address = homePage.getAddress()
        back()
        let newOpPage = NewOperationPage()
        let descriptionPage = NewOpDescriptionPage()
        let mempoolStartingSize = mempoolCount()

        tryUriEdgeCases(homePage: homePage, newOpPage: newOpPage, address: address)

        addSection("pay to full uri - setup")

        // Assemble a prefilled uri and input that
        let fullUri = "bitcoin:\(address)?amount=0.1&label=Champo&message=foo"
        _ = homePage.enter(address: fullUri)

        addSection("pay to full uri - confirm")
        assertConfirm(to: "Champo", amount: formatBTCAmount(0.1), descriptionText: "foo", in: newOpPage)
        assertPay(newOpPage, homePage)

        addSection("pay to partial uri - setup")

        // Assemble a prefilled uri without description and input that
        let uri = "bitcoin:\(address)?amount=0.1&label=Champo"
        _ = homePage.enter(address: uri)

        addSection("pay to partial uri - description")

        enterDescription(newOpPage, descriptionPage)

        // Check we're in the confirm screen and the button is enabled
        assertConfirm(to: "Champo", amount: formatBTCAmount(0.1), descriptionText: descriptionText, in: newOpPage)
        assertDescriptionAfterBack(descriptionPage, newOpPage)

        // Submit the description
        newOpPage.touchContinueButton()

        addSection("pay to partial uri - confirm")

        assertConfirm(to: "Champo", amount: formatBTCAmount(0.1), descriptionText: descriptionText, in: newOpPage)
        assertPay(newOpPage, homePage)

        let transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: mempoolStartingSize + 2)
        XCTAssertEqual(mempoolCount(), mempoolStartingSize + 2, "We must have 2 new unconfirmed TXs")
    }

    // TestPay to a bech32 Address
    func testAllFundsToBech32() {
        addSection("setup")

        let homePage = setupUser()

        let mempoolStartingSize = mempoolCount()

        // Enter a valid bech32 address
        let address = getBech32Address()
        let newOpPage = homePage.enter(address: address)
        let amountPage = NewOpAmountPage()
        let descriptionPage = NewOpDescriptionPage()

        addSection("pay to bech32 address - amount")
        assertAmountPage(amountPage, newOpPage)

        // Use all funds
        amountPage.useAllFunds()

        addSection("pay to bech32 address - description")

        enterDescription(newOpPage, descriptionPage)

        addSection("pay to bech32 address - edit fee")

        newOpPage.selectMediumFee()
        newOpPage.manuallyEnterFee(amount: 50)

        assertPay(newOpPage, homePage)

        let transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: mempoolStartingSize + 1)
        XCTAssertEqual(mempoolCount(), mempoolStartingSize + 1, "We must have 1 new unconfirmed TX")
    }

    // MARK: Submarine swap test
    func testSubmarineSwap() {
        addSection("setup")

        let homePage = setupUser()
        let mempoolStartingSize = mempoolCount()

        addSection("New op - Submarine Swap")
        let descriptionPage = NewOpDescriptionPage()
        // 35k is enough to avoid the swap being a lend
        let (invoice, destination) = getLightningInvoice(satoshis: "35000")
        let newOpPage = homePage.enter(address: invoice)
        descriptionPage.wait(10)

        enterDescription(newOpPage, descriptionPage)

        assertConfirm(to: destination, amount: formatBTCAmount(0.00035), descriptionText: descriptionText, in: newOpPage)
        assertPay(newOpPage, homePage)

        let transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: mempoolStartingSize + 1)
        XCTAssertEqual(mempoolCount(), mempoolStartingSize + 1, "We must have 1 new unconfirmed TXs")
    }

    func testFastFeeEdgeCases() {
        addSection("setup")
        var homePage = setupUser()
        let address = homePage.getAddress()
        back()
        let mempoolStartingSize = mempoolCount()

        let newOpPage = homePage.enter(address: address)
        var amountPage = NewOpAmountPage()
        let descriptionPage = NewOpDescriptionPage()

        amountPage = notEnoughFundsForFastFee(amount: "0.9999",
                                              newOpPage: newOpPage,
                                              amountPage: amountPage,
                                              descriptionPage: descriptionPage)

        homePage = notEnoughFundsForMinimumFee(amount: "0.9999999",
                                               newOpPage: newOpPage,
                                               amountPage: amountPage,
                                               descriptionPage: descriptionPage)

        let transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: mempoolStartingSize)
        XCTAssertEqual(mempoolCount(), mempoolStartingSize, "We must have 0 new unconfirmed TXs")
    }

    func testBip70() {
        addSection("setup user")

        let homePage = setupUser()
        let initialMempoolSize = mempoolCount()
        let initialOperationCount = 2 // The user just received 2 operations
        var currentBalance = formatBTCAmount(1.00, format: .short)
        homePage.assert(balance: currentBalance)

        let bip70Url = bip70Invoice()
        addSection("New op - 10.000 sats BIP0070")
        let newOpPage = homePage.enter(address: bip70Url)
        newOpPage.wait()
        assertConfirm(
            to: "bcrt1qcnjd3rs0pwh92qpmlvwj2p88tnf0qmpmxd5qfc",
            amount: formatBTCAmount(0.0001),
            descriptionText: "Payment Request BIP0070",
            in: newOpPage
        )
        assertPay(newOpPage, homePage)
        let expectedOperationCount = initialOperationCount + 1
        let expectedMempoolSize = initialMempoolSize + 1

        let transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: expectedOperationCount)
        XCTAssertEqual(mempoolCount(), expectedMempoolSize, "We must have 1 new unconfirmed TXs in the mempool")

        backTo(page: homePage)

        // Current balance is 1 BTC - 10000 sats of the bip70 invoice - 83600 sats for next block fee = 0.99906400
        currentBalance = formatBTCAmount(0.99906400, format: .short)
        homePage.assert(balance: currentBalance)
    }

    /**
        This test does 4 things:
        1. User aquires 10.000 sats of debt (0-conf swap).
        2. User pays another 20.000 sats (0-conf swaps) and the server collects the debt.
        3. User aquires 200 sats of debt (0-conf swap)
        4. User uses all funds and the server forgives the debt
     */
    func testUserDebt() {
        addSection("setup user")

        let homePage = setupUser()
        var mempoolSize = mempoolCount()
        var operationCount = mempoolSize
        var currentBalance = formatBTCAmount(1.00, format: .short)

        homePage.assert(balance: currentBalance)

        addSection("New op - 10.000 sats Lend swap")
        let descriptionPage = NewOpDescriptionPage()
        let (lendInvoice, destination) = getLightningInvoice(satoshis: "10000")
        var newOpPage = homePage.enter(address: lendInvoice)
        descriptionPage.wait(10)

        enterDescription(newOpPage, descriptionPage)
        assertConfirm(to: destination, amount: formatBTCAmount(0.0001), descriptionText: descriptionText, in: newOpPage)
        assertPay(newOpPage, homePage)
        operationCount += 1

        var transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: operationCount)
        // There wasn't any on chain tx
        XCTAssertEqual(mempoolCount(), mempoolSize, "We must have no new unconfirmed TXs in the mempool")

        backTo(page: homePage)

        // Current balance is 1 BTC - 10000 sats of the invoice = 0.99990000
        currentBalance = formatBTCAmount(0.99990000, format: .short)
        homePage.assert(balance: currentBalance)

        addSection("New op - 20.000 sats Collect swap")
        let (collectInvoice, destination2) = getLightningInvoice(satoshis: "20000")

        newOpPage = homePage.enter(address: collectInvoice)
        descriptionPage.wait(10)

        enterDescription(newOpPage, descriptionPage)
        assertConfirm(to: destination2, amount: formatBTCAmount(0.0002), descriptionText: descriptionText, in: newOpPage)
        assertPay(newOpPage, homePage)
        operationCount += 1
        mempoolSize += 1

        transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: operationCount)
        XCTAssertEqual(mempoolCount(), mempoolSize, "We must have 1 new unconfirmed TXs in the mempool")

        backTo(page: homePage)

        // This tx will use 1 sat/vbyte -> 209 sats (using 0 sats for routing fee)
        currentBalance = formatBTCAmount(0.99969791, format: .short)
        homePage.assert(balance: currentBalance)

        addSection("New op - 200 sats Lend swap")
        let (lendInvoice2, destination3) = getLightningInvoice(satoshis: "200")
        newOpPage = homePage.enter(address: lendInvoice2)
        descriptionPage.wait(10)

        enterDescription(newOpPage, descriptionPage)
        assertConfirm(to: destination3, amount: formatBTCAmount(0.000002), descriptionText: descriptionText, in: newOpPage)
        assertPay(newOpPage, homePage)
        operationCount += 1

        transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: operationCount)
        // There wasn't any on chain tx
        XCTAssertEqual(mempoolCount(), mempoolSize, "We must have no new unconfirmed TXs in the mempool")

        backTo(page: homePage)

        // This assert will crash if we ever change the fees for debug mode
        currentBalance = formatBTCAmount(0.99969591, format: .short) // 200 sats less for the invoice
        homePage.assert(balance: currentBalance)

        addSection("Sweep funds - Forgive debt test")
        let address = getBech32Address()
        newOpPage = homePage.enter(address: address)
        let amountPage = NewOpAmountPage()
        // Use all funds
        amountPage.useAllFunds()
        enterDescription(newOpPage, descriptionPage)
        assertPay(newOpPage, homePage)
        operationCount += 1
        mempoolSize += 1

        transactionsPage = homePage.openOperationsList()
        transactionsPage.assertOperationsCount(equalTo: operationCount)
        XCTAssertEqual(mempoolCount(), mempoolSize, "We must have 1 new unconfirmed TX")

        backTo(page: homePage)

        currentBalance = formatBTCAmount(0, format: .short)
        homePage.assert(balance: currentBalance)
    }

    fileprivate func assertEmptyAmount(_ amountPage: NewOpAmountPage, _ newOpPage: NewOperationPage) {
        // Wipe the amount and check the button is disabled
        amountPage.enter(amount: "")
        XCTAssertFalse(newOpPage.isContinueEnabled(), "Wiping the amount should disable the button")
    }

    fileprivate func assertLargeAmount(_ amountPage: NewOpAmountPage, _ newOpPage: NewOperationPage) {
        // Enter an amount insanely big and check the button is disabled, also check the currency label is still visible
        amountPage.enter(amount: "123456789101.23")
        XCTAssertFalse(newOpPage.isContinueEnabled(), "Insanely big amount should not be payable")
        XCTAssert(amountPage.isCurrencyVisible())
        XCTAssertEqual("123,456,789,101.23", amountPage.amount(), "Formatting should be applied")
    }

    fileprivate func enterDescription(_ newOpPage: NewOperationPage, _ descriptionPage: NewOpDescriptionPage) {
        XCTAssert(descriptionPage.exists())

        // Button should be disabled
        XCTAssertFalse(newOpPage.isContinueEnabled(), "Empty description shuld disable the button")
        XCTAssert(newOpPage.hasAmountFilledData(), "Amount should be visible while inputing description")
        XCTAssert(newOpPage.hasDestinationFilledData(), "Destination step should be visible while inputing description")
        XCTAssertFalse(newOpPage.hasDescriptionFilledData())
        XCTAssertFalse(newOpPage.hasAmountAndFeeFilledData(), "fee should be hidden in description")

        // Enter a silly description and keep going
        descriptionPage.enter(description: descriptionText)
        newOpPage.touchContinueButton()
    }

    fileprivate func assertDescriptionAfterBack(_ descriptionPage: NewOpDescriptionPage,
                                                _ newOpPage: NewOperationPage) {

        // Go back and check the description is still there
        back()
        XCTAssertEqual(descriptionText, descriptionPage.description(), "Description should be remembered on back")
        XCTAssert(newOpPage.isContinueEnabled())
    }

    fileprivate func setupUser() -> HomePage {
        return createUser(utxos: [0.5, 0.5])
    }

    private func assertConfirm(to: String, amount: String, descriptionText: String, in newOpPage: NewOperationPage) {

        // Check we're in the confirm screen and the button is enabled
        XCTAssert(newOpPage.isContinueEnabled(), "We should jump to confirm and be able to pay")
        newOpPage.wait()

        XCTAssert(newOpPage.hasAmountAndFeeFilledData(), "Amount and fee should be visible in confirm")
        XCTAssert(newOpPage.hasDestinationFilledData(), "Destination should be visible in confirm")
        XCTAssert(newOpPage.hasDescriptionFilledData(), "Description should be visible in confirm")
        XCTAssert(newOpPage.isContinueEnabled(), "Continue is always enabled in confirm view")
        let filledDataInfo = newOpPage.filledData()

        XCTAssert(filledDataInfo.to.hasPrefix(to.prefix(4)) && filledDataInfo.to.hasSuffix(to.suffix(4)),
                      "destination should match")
        XCTAssertEqual(filledDataInfo.amount, amount, "amount should match inserted amount")
        XCTAssertFalse(filledDataInfo.fee.isEmpty, "fee shouldnt be empty")
        XCTAssertEqual(filledDataInfo.description, descriptionText, "description should match")
    }

    fileprivate func assertAmountAfterBack(_ amountPage: NewOpAmountPage, _ newOpPage: NewOperationPage) {
        // Go back and check the amount is still there
        back()
        XCTAssertEqual(amount, amountPage.amount(), "Amount should be remembered on back")
        XCTAssert(newOpPage.isContinueEnabled())
    }

    fileprivate func assertPay(_ newOpPage: NewOperationPage, _ homePage: HomePage) {
        // Submit the payment
        newOpPage.touchContinueButton()
        homePage.wait(10)
        XCTAssert(homePage.exists())
    }

    fileprivate func assertAmountPage(_ amountPage: NewOpAmountPage, _ newOpPage: NewOperationPage) {
        XCTAssert(amountPage.exists(timeout: 10), "Inputing a valid address should take you to amount")
        XCTAssertFalse(newOpPage.isContinueEnabled(), "An amount has to be entered before continuing")

        XCTAssert(newOpPage.hasDestinationFilledData(), "Destination step should be visible while inputing description")
        XCTAssertFalse(newOpPage.hasAmountFilledData())
        XCTAssertFalse(newOpPage.hasDescriptionFilledData())
        XCTAssertFalse(newOpPage.hasAmountAndFeeFilledData(), "fee should be hidden in description")
    }

    private func selectBitcoinCurrency(in amountPage: NewOpAmountPage) -> NewOpAmountPage {
        let currencyPage = amountPage.tapCurrency()
        let amountPageUpdated = currencyPage.selectCurrency(index: 0)
        amountPageUpdated.assertCurrencyText("BTC")
        return amountPageUpdated
    }

    private func notEnoughFundsForFastFee(amount: String,
                                          newOpPage: NewOperationPage,
                                          amountPage: NewOpAmountPage,
                                          descriptionPage: NewOpDescriptionPage) -> NewOpAmountPage {
        addSection("Test not enough funds to cover fast fee")
        assertAmountPage(amountPage, newOpPage)

        let newAmountPage = selectBitcoinCurrency(in: amountPage)
        newAmountPage.enter(amount: amount)
        newOpPage.touchContinueButton()
        enterDescription(newOpPage, descriptionPage)
        _ = app.wait(for: .unknown, timeout: 1)

        // Continue button should be disabled
        XCTAssertFalse(newOpPage.isContinueEnabled())
        // Go back to amount state
        back()
        back()

        return newAmountPage
    }

    private func notEnoughFundsForMinimumFee(amount: String,
                                             newOpPage: NewOperationPage,
                                             amountPage: NewOpAmountPage,
                                             descriptionPage: NewOpDescriptionPage) -> HomePage {
        addSection("Test not enough funds to cover minimum fee")
        amountPage.clearText()
        amountPage.enter(amount: amount)

        // Submit the amount
        newOpPage.touchContinueButton()

        let errorPage = NewOpErrorPage()
        errorPage.assertInsufficientFunds()
        return errorPage.backToHome()
    }

    private func tryUriEdgeCases(homePage: HomePage, newOpPage: NewOperationPage, address: String) {
        let errorPage = NewOpErrorPage()

        addSection("pay to fixed amount uris - amount below dust")

        let dustUri = "bitcoin:\(address)?amount=0.000001"
        tryInsufficientFundsScreen(address: dustUri, homePage: homePage, dustError: true)

        addSection("pay to fixed amount uris - amount greater than balance")

        let highAmountUri = "bitcoin:\(address)?amount=2"
        tryInsufficientFundsScreen(address: highAmountUri, homePage: homePage)

        addSection("pay to fixed amount uris - amount equal total balance")

        let totalBalanceUri = "bitcoin:\(address)?amount=1"
        // With fixed amounts we cant take fee from amount so the error should be displayed
        tryInsufficientFundsScreen(address: totalBalanceUri, homePage: homePage)

        addSection("pay to fixed amount uris - amount plus minimum fee greater than total balance")

        let amountPlusMinimumFeeTooHighUri = "bitcoin:\(address)?amount=0.999999"
        tryInsufficientFundsScreen(address: amountPlusMinimumFeeTooHighUri, homePage: homePage)

        addSection("pay to fixed amount uris - amount not payable with fast fee but payable with the minimum fee")

        let amountPayableUri = "bitcoin:\(address)?amount=0.9999&message=Testeando"
        _ = homePage.enter(address: amountPayableUri)
        // Continue button should be disabled
        XCTAssertFalse(newOpPage.isContinueEnabled())
        // Error page wont exist
        XCTAssertFalse(errorPage.exists())

        back()
        abortNewOp()
        backTo(page: homePage)
    }

    private func tryInsufficientFundsScreen(address: String, homePage: HomePage, dustError: Bool = false) {
        let errorPage = NewOpErrorPage()
        _ = homePage.enter(address: address)
        XCTAssert(errorPage.exists())
        if dustError {
            errorPage.assertDustError()
        } else {
            errorPage.assertInsufficientFunds()
        }
        _ = errorPage.backToHome()
    }

    private func abortNewOp() {
        back()
        app.alerts[L10n.NewOperationViewController.s3].buttons[L10n.NewOperationViewController.s6].tap()
    }

}
