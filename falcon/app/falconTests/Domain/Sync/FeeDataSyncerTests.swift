//
//  FeeDataSyncerTests.swift
//  falconTests
//
//  Created by Daniel Mankowski on 04/11/2024.
//  Copyright © 2024 muun. All rights reserved.
//

@testable import Muun
import RxSwift
import XCTest

final class FeeDataSyncerTests: MuunTestCase {

    private var feeDataSyncer: FeeDataSyncer!
    private var fakePreloadFeeDataAction: FakePreloadFeeDataAction!
    private var nextTransactionSizeRepository: NextTransactionSizeRepository!
    private var processingObservable: PublishSubject<NotificationProcessingState>!
    private lazy var featureFlagsRepository: FeatureFlagsRepository = resolve()

    override func setUp() {
        super.setUp()

        featureFlagsRepository.store(flags: [.effectiveFeesCalculation])
        fakePreloadFeeDataAction = replace(.singleton, PreloadFeeDataAction.self, FakePreloadFeeDataAction.init)
        nextTransactionSizeRepository = resolve()
        processingObservable = PublishSubject<NotificationProcessingState>()

        let observable = processingObservable.asObservable()
        feeDataSyncer = FeeDataSyncer(preloadFeeDataAction: fakePreloadFeeDataAction,
                                      nextTransactionRepository: nextTransactionSizeRepository,
                                      ntsChangesObservable: observable,
                                      featureFlagsRepository: featureFlagsRepository)
    }

    func test_withNTSEmpty_shouldNotCallForceRun() {
        feeDataSyncer.appDidBecomeActive()

        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(0, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withNTSNotEmptyAndNoChanges_shouldNotCallForceRun() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))

        feeDataSyncer.appDidBecomeActive()

        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(0, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withNTSChangesAndUnconfirmedStatus_shouldCallForceRun() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(1, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withNTSChangesAndConfirmedStatus_shouldNotCallForceRun() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .CONFIRMED))
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(0, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withTwoStartedAndTwoCompleted_shouldCallForceRunOneTime() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.completed)
        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.1 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(1, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withThreeStartedAndThreeCompleted_shouldCallForceRunOneTime() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)
        processingObservable.onNext(.started)
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.completed)
        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)
        processingObservable.onNext(.completed)
        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(1, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withTwoStartedAndOneCompleted_shouldNotCallForceRun() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(0, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withTwoCompleteGroupOfTasks_shouldCallForceRunTwice() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.completed)

        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.started)

        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(2, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    func test_withNTSChangesBeforeCompletedIsCalled_shouldCallForceRun() {
        nextTransactionSizeRepository.setNextTransactionSize(makeInitialNTS(status: .UNCONFIRMED))
        feeDataSyncer.appDidBecomeActive()
        processingObservable.onNext(.started)

        XCTAssertEqual(0, fakePreloadFeeDataAction.forceRunCalledCount)

        // The idea is to check that initial sizeProgression is used in comparison
        // Please note .started is called with final sizeProgression but it is not used in
        // FeeDataSyncer.
        nextTransactionSizeRepository.setNextTransactionSize(makeFinalNTS(status: .UNCONFIRMED))
        processingObservable.onNext(.started)

        processingObservable.onNext(.completed)
        processingObservable.onNext(.completed)

        let expectation: XCTestExpectation = expectation(description: "wait for 0.2 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertEqual(1, self.fakePreloadFeeDataAction.forceRunCalledCount)
        }
    }

    // MARK: Helpers

    private func makeInitialNTS(status: UtxoStatus) -> NextTransactionSize {
        let progression = [
            SizeForAmount(amountInSatoshis: Satoshis(value: 1000),
                          sizeInBytes: 0,
                          outpoint: "a:0",
                          utxoStatus: status)
        ]

        return NextTransactionSize(sizeProgression: progression,
                                           validAtOperationHid: 0,
                                           _expectedDebt: Satoshis(value: 0))
    }

    private func makeFinalNTS(status: UtxoStatus) -> NextTransactionSize {
        let progression = [
            SizeForAmount(amountInSatoshis: Satoshis(value: 1000),
                          sizeInBytes: 0,
                          outpoint: "b:0",
                          utxoStatus: status)
        ]

        return NextTransactionSize(sizeProgression: progression,
                                           validAtOperationHid: 0,
                                           _expectedDebt: Satoshis(value: 0))
    }
}
