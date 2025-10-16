//
//  PreloadFeeDataActionTests.swift
//  falconTests
//
//  Created by Daniel Mankowski on 25/10/2024.
//  Copyright © 2024 muun. All rights reserved.
//

@testable import Muun
import XCTest

final class PreloadFeeDataActionTests: MuunTestCase {

    private var action: PreloadFeeDataAction!
    private var fakeHoustonService: FakeHoustonService!
    private var fakeLibwalletService: FakeLibwalletService!
    private lazy var featureFlagsRepository: FeatureFlagsRepository = resolve()

    override func setUp() {
        super.setUp()

        featureFlagsRepository.store(flags: [.effectiveFeesCalculation])
        fakeHoustonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        fakeLibwalletService = replace(.singleton, LibwalletService.self, FakeLibwalletService.init)
        action = resolve()
        setUpBasicData()
    }

    override func tearDown() {
        action.reset()
        super.tearDown()
    }

    func testRunTwiceShouldRunOneTimeBecauseOfThrottling() {

        fakeHoustonService.fetchRealTimeFeesCalledCount = 0
        fakeLibwalletService.persistFeeBumpFunctionsCalledCount = 0

        action.run()

        wait(for: action.getValue())
        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 1)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 1)

        action.run()

        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 1)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 1)
    }

    func testRunTwiceWithThrottlingIntervalShouldRunTwoTimes() {

        let throttlingTime: TimeInterval = 0.3

        fakeHoustonService.fetchRealTimeFeesCalledCount = 0
        fakeLibwalletService.persistFeeBumpFunctionsCalledCount = 0

        action.run()

        wait(for: action.getValue())
        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 1)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 1)

        let expectation: XCTestExpectation = expectation(description: "throttling delay")
        // ThrottlingInterval = 0.3 for testing mode
        DispatchQueue.main.asyncAfter(deadline: .now() + throttlingTime) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) {_ in
            self.action.reset()
            self.action.run()

            self.wait(for: self.action.getValue())
            XCTAssertEqual(self.fakeHoustonService.fetchRealTimeFeesCalledCount, 2)
            XCTAssertEqual(self.fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 2)
        }
    }

    func testForceRunTwiceShouldCallServicesTwoTimes() {

        fakeHoustonService.fetchRealTimeFeesCalledCount = 0
        fakeLibwalletService.persistFeeBumpFunctionsCalledCount = 0

        action.forceRun(refreshPolicy: .ntsChanged)

        wait(for: action.getValue())
        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 1)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 1)

        action.reset()
        action.forceRun(refreshPolicy: .ntsChanged)

        wait(for: action.getValue())
        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 2)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 2)
    }

    func testRunAndForceRunWithFFOffNotShouldCallServices() {

        featureFlagsRepository.store(flags: [])

        fakeHoustonService.fetchRealTimeFeesCalledCount = 0
        fakeLibwalletService.persistFeeBumpFunctionsCalledCount = 0

        action.run()

        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 0)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 0)

        action.forceRun(refreshPolicy: .ntsChanged)

        XCTAssertEqual(fakeHoustonService.fetchRealTimeFeesCalledCount, 0)
        XCTAssertEqual(fakeLibwalletService.persistFeeBumpFunctionsCalledCount, 0)
    }

    // MARK: Helpers
    private func setUpBasicData() {
        let nextTransactionSizeRepository: NextTransactionSizeRepository = resolve()

        let progression = [
            SizeForAmount(amountInSatoshis: Satoshis(value: 1000),
                          sizeInBytes: 0,
                          outpoint: "a:0",
                          utxoStatus: .UNCONFIRMED)
        ]
        let nextSize = NextTransactionSize(sizeProgression: progression,
                                           validAtOperationHid: 0,
                                           _expectedDebt: Satoshis(value: 90))

        nextTransactionSizeRepository.setNextTransactionSize(nextSize)
    }
}
