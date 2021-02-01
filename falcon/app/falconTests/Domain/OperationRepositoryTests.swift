//
//  OperationRepositoryTests.swift
//  core.root-all-notifications-Unit-Tests
//
//  Created by Federico Bond on 05/01/2021.
//

import XCTest
import Firebase
@testable import core
@testable import falcon

class OperationRepositoryTests: MuunTestCase {

    var operationRepository: OperationRepository!

    override func setUp() {
        super.setUp()
        operationRepository = resolve()
    }

    func testGetOperationsState() {
        let state = operationRepository.getOperationsState()
        XCTAssertTrue(state == .confirmed)

        let op = Factory.pendingIncomingOperation()
        wait(for: operationRepository.storeOperations([op]))

        let state2 = operationRepository.getOperationsState()
        XCTAssertTrue(state2 == .pending)

        let op2 = Factory.pendingIncomingOperation(isRBF: true)
        wait(for: operationRepository.storeOperations([op2]))

        let state3 = operationRepository.getOperationsState()
        XCTAssertTrue(state3 == .cancelable)
    }

    func testHasPendingOperations() {
        let op = Factory.operation(status: OperationStatus.SETTLED)
        wait(for: operationRepository.storeOperations([op]))

        XCTAssertFalse(operationRepository.hasPendingOperations())

        let op2 = Factory.pendingOutgoingOperation()
        wait(for: operationRepository.storeOperations([op2]))

        XCTAssertTrue(operationRepository.hasPendingOperations())
    }

    func testHasPendingSwaps() {
        let op = Factory.operation(status: OperationStatus.SWAP_PAYED)
        wait(for: operationRepository.storeOperations([op]))

        XCTAssertFalse(operationRepository.hasPendingSwaps())

        let op2 = Factory.operation(status: .SWAP_PENDING)
        wait(for: operationRepository.storeOperations([op2]))

        XCTAssertTrue(operationRepository.hasPendingSwaps())
    }

    func testHasPendingIncomingSwaps() {
        let op = Factory.pendingIncomingOperation()
        wait(for: operationRepository.storeOperations([op]))

        XCTAssertFalse(operationRepository.hasPendingIncomingSwaps())

        let op2 = Factory.incomingSwapOperation(status: .SETTLED)
        wait(for: operationRepository.storeOperations([op2]))

        XCTAssertFalse(operationRepository.hasPendingIncomingSwaps())

        let op3 = Factory.incomingSwapOperation(status: .BROADCASTED)
        wait(for: operationRepository.storeOperations([op3]))

        XCTAssertTrue(operationRepository.hasPendingIncomingSwaps())
    }

}
