//
//  HomePresenterTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 19/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import XCTest
import RxBlocking
@testable import core
@testable import Muun

class HomePresenterTests: MuunTestCase {
    
    func testBalanceZero() {
        expectBalance(expectedBalance: "0")
    }
    
    func testBalanceWithIncoming() {
        setupBasicData()

        let nextTransactionSizeRepository: NextTransactionSizeRepository = resolve()

        let progression = [
            SizeForAmount(amountInSatoshis: Satoshis(value: 100),
                          sizeInBytes: 0,
                          outpoint: "a:0",
                          utxoStatus: .CONFIRMED)
        ]
        let nextSize = NextTransactionSize(sizeProgression: progression,
                                           validAtOperationHid: 0,
                                           _expectedDebt: Satoshis(value: 0))

        nextTransactionSizeRepository.setNextTransactionSize(nextSize)
        
        expectBalance(expectedBalance: "0.000001")
    }

    func testBalanceWithIncomingAndDebt() {
        setupBasicData()

        let nextTransactionSizeRepository: NextTransactionSizeRepository = resolve()

        let progression = [
            SizeForAmount(amountInSatoshis: Satoshis(value: 1000),
                          sizeInBytes: 0,
                          outpoint: "a:0",
                          utxoStatus: .CONFIRMED)
        ]
        let nextSize = NextTransactionSize(sizeProgression: progression,
                                           validAtOperationHid: 0,
                                           _expectedDebt: Satoshis(value: 90))

        nextTransactionSizeRepository.setNextTransactionSize(nextSize)

        expectBalance(expectedBalance: "0.0000091")
    }

    func testBalanceWithIncomingAndNegativeDebt() {
        setupBasicData()

        let nextTransactionSizeRepository: NextTransactionSizeRepository = resolve()

        let progression = [
            SizeForAmount(amountInSatoshis: Satoshis(value: 1000),
                          sizeInBytes: 0,
                          outpoint: "a:0",
                          utxoStatus: .CONFIRMED)
        ]
        let nextSize = NextTransactionSize(
            sizeProgression: progression,
            validAtOperationHid: 0,
            _expectedDebt: Satoshis(value: -90)
        )

        nextTransactionSizeRepository.setNextTransactionSize(nextSize)

        // If we have negative debt, we'll log an error but we'll assume debt is actually 0
        expectBalance(expectedBalance: "0.00001")
    }

    func testBalanceZeroBalanceNegativeDebt() {
        setupBasicData()

        let nextTransactionSizeRepository: NextTransactionSizeRepository = resolve()
        let nextSize = NextTransactionSize(
            sizeProgression: [],
            validAtOperationHid: 0,
            _expectedDebt: Satoshis(value: -1000)
        )

        nextTransactionSizeRepository.setNextTransactionSize(nextSize)

        // If the size progression is empty, the balance will always be 0, no matter the debt
        expectBalance(expectedBalance: "0")
    }
    
    private func expectBalance(expectedBalance: String) {
        let expectation = self.expectation(description: "balance")
        
        let delegate = BalanceDelegate(expectation: expectation, expectedBalance: Decimal(string: expectedBalance)!)
        
        do {
            let presenter = instancePresenter(HomePresenter.init, delegate: delegate)
        
            presenter.setUp()
            // Use defer to make sure this is always called
            defer {
                presenter.tearDown()
            }
        
            waitForExpectations(timeout: 2, handler: nil)
        }
    }
}

private class BalanceDelegate: ExpectablePresenterDelegate, HomePresenterDelegate {

    func showWelcome() {
        // Do nothing
    }

    func showTaprootActivated() {
        // Do nothing
    }

    func onCompanionChange(_ companion: HomeCompanion) {
        // Do nothing
    }

    func didReceiveNewOperation(amount: MonetaryAmount, direction: OperationDirection) {
        // Do nothing
    }

    func onBalanceVisibilityChange(_ isHidden: Bool) {
        // Do nothing
    }

    func onHasRecoveryCodeChange() {
        // Do nothing
    }
    
    let expectedBalance: Decimal
    
    init(expectation: XCTestExpectation, expectedBalance: Decimal) {
        self.expectedBalance = expectedBalance
        super.init(expectation: expectation)
    }
    
    func onOperationsChange() {}
    
    func onBalanceChange(_ balance: MonetaryAmount) {
        XCTAssertEqual(balance.amount, expectedBalance)
        
        self.expectation.fulfill()
    }
    
}
