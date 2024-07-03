//
//  HomePage.swift
//  falconUITests
//
//  Created by Manu Herrera on 11/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

final class HomePage: UIElementPage<UIElements.Pages.HomePage> {

    private let receiveButton = SmallButtonViewPage(Root.receive)
    private let sendButton = SmallButtonViewPage(Root.send)
    private lazy var confirmWelcome = SmallButtonViewPage(Root.letsGo)
    private lazy var chevron = otherElement(Root.chevron)
    private lazy var balanceLabel = label(.balance)

    init() {
        super.init(root: Root.root)
    }
    
    func tapReceive() -> ReceivePage {
        receiveButton.mainButtonTap()
        return ReceivePage()
    }

    func tapSend() -> ScanQRPage {
        sendButton.mainButtonTap()
        return ScanQRPage()
    }

    func openOperationsList() -> TransactionListPage {
        chevron.tap()
        return TransactionListPage()
    }

    func assert(balance: String) {
        let balanceText = balanceLabel.label
        XCTAssert(balanceText.contains(balance), failureMessage(expected: balance, actual: balanceText))
    }

    func dismissPopUp() {
        // Wait for the pop up to appear
        sleep(2)

        confirmWelcome.mainButtonTap()

    }

    func getAddress() -> String {
        let receivePage = tapReceive()
        receivePage.wait()
        return receivePage.address()
    }

    func getInvoice() -> String {
        let receivePage = tapReceive()
        receivePage.wait()
        return receivePage.invoice()
    }

    func enter(address: String) -> NewOperationPage {
        // Avoid the clipboard detection feature
        UIPasteboard.general.string = "not-an-address"

        let scanQRPage = tapSend()
        let newOpPage = scanQRPage.enterManually()
            .send(to: address)

        // We might have a spinner here
        newOpPage.wait(15)
        return newOpPage
    }

    func toggleBalanceVisibility() {
        balanceLabel.tap()
    }

}
