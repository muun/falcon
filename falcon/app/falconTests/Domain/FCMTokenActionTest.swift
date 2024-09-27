//
//  FCMTokenActionTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 22/05/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import XCTest
@testable import core

class FCMTokenActionTest: MuunTestCase {
    private let fakeToken = "fakeToken"
    private let secondFakeToken = "secondFakeToken"

    var timer: MUTimerFake!
    var houstonService: FakeHoustonService!
    var subject: FCMTokenAction!
    var sessionRepository: SessionRepository!
    var preferences: Preferences!
    var expectation: XCTestExpectation?

    override func setUp() {
        super.setUp()
        preferences = resolve()
        houstonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        timer = replace(.singleton, MUTimer.self, MUTimerFake.init)
        sessionRepository = resolve()

        // This expectation is surviving among tests causing problems.
        houstonService.updateGcmTokenExpectation = nil
        
        subject = resolve()
    }
    
    override func tearDown() {
        super.tearDown()

        // Expectations must only live in the scope of one test only
        self.houstonService.updateGcmTokenExpectation = nil
    }


    func test_runLoggedOut() {
        sessionRepository.setStatus(.CREATED)
        
        subject.run(token: fakeToken)
        
        XCTAssertEqual(preferences.string(forKey: .gcmToken), fakeToken)
        XCTAssertEqual(houstonService.updateGcmTokenCalledCount, 0)
    }

    func test_runSuccessfully() {
        sessionRepository.setStatus(.LOGGED_IN)
        houstonService.canUpdateGcmToken = true

        subject.run(token: fakeToken)

        XCTAssertEqual(preferences.string(forKey: .gcmToken), fakeToken)
        XCTAssertEqual(houstonService.updateGcmTokenCalledCount, 1)
        XCTAssertEqual(timer.stopCalledCount, 1)
        XCTAssertTrue(self.preferences.bool(forKey: .gcmTokenSynced))
    }

    func test_enterFailureModeOnUpdateFailed() {
        sessionRepository.setStatus(.LOGGED_IN)
        houstonService.canUpdateGcmToken = false

        subject.run(token: fakeToken)

        XCTAssertEqual(preferences.string(forKey: .gcmToken), fakeToken)
        XCTAssertEqual(houstonService.updateGcmTokenCalledCount, 1)
        XCTAssertEqual(timer.stopCalledCount, 1)
        XCTAssertEqual(timer.startCalledCount, 1)
        XCTAssertFalse(self.preferences.bool(forKey: .gcmTokenSynced))
    }

    func test_syncAgainOnNewTokenReceivedWhileSyncing() {
        houstonService.updateGcmTokenExpectation = expectation(description: "Wait for houston to be called twice")
        houstonService.updateGcmTokenExpectation?.expectedFulfillmentCount = 2

        sessionRepository.setStatus(.LOGGED_IN)
        //prevent houston from responding on time
        houstonService.shouldRespondToUpdateGcmToken.onNext(false)

        // we are syncing so next call will be ignored
        subject.run(token: fakeToken)
        // Ignored call
        subject.run(token: secondFakeToken)
        // Trigger the logic to detect last token has not been synced.
        houstonService.shouldRespondToUpdateGcmToken.onNext(true)

        waitForExpectations(timeout: 3.0) { _ in
            XCTAssertEqual(self.preferences.string(forKey: .gcmToken), self.secondFakeToken)
            XCTAssertEqual(self.houstonService.updateGcmTokenCalledCount, 2)
            XCTAssertEqual(self.timer.stopCalledCount, 2)
            XCTAssertEqual(self.houstonService.lastSyncedGCMToken, self.secondFakeToken)
            XCTAssertTrue(self.preferences.bool(forKey: .gcmTokenSynced))
        }
    }

    func test_tokensFromFcmHavePriorityOverEncoledParanoidModeTokens() {
        houstonService.updateGcmTokenExpectation = expectation(description: "Wait for houston to be called twice")
        houstonService.updateGcmTokenExpectation?.expectedFulfillmentCount = 2

        sessionRepository.setStatus(.LOGGED_IN)
        //prevent houston from responding on time
        houstonService.shouldRespondToUpdateGcmToken.onNext(false)

        // we are syncing so next call will be ignored
        subject.run(token: fakeToken, runFromFailureMode: false)
        // Ignored call
        subject.run(token: secondFakeToken, runFromFailureMode: false)
        // Ignored call
        subject.run(token: fakeToken, runFromFailureMode: true)
        // Trigger the logic to detect last token has not been synced.
        houstonService.shouldRespondToUpdateGcmToken.onNext(true)

        waitForExpectations(timeout: 3.0) { _ in
            XCTAssertEqual(self.preferences.string(forKey: .gcmToken), self.secondFakeToken)
            XCTAssertEqual(self.houstonService.updateGcmTokenCalledCount, 2)
            XCTAssertEqual(self.timer.stopCalledCount, 2)
            XCTAssertEqual(self.houstonService.lastSyncedGCMToken, self.secondFakeToken)
            XCTAssertTrue(self.preferences.bool(forKey: .gcmTokenSynced))
        }
    }

    func test_runOnTimerTicWhenInFailureMode() throws {
        try XCTSkipIf(true, "passes locally but fails on bitrise")

        expectation = expectation(description: "wait_for_success")
        expectation?.expectedFulfillmentCount = 2

        subscribeTo(subject.getValue(),
                    onSuccess: { XCTFail() },
                    onError: { error in self.expectation?.fulfill() })

        //enter in failure mode
        sessionRepository.setStatus(.LOGGED_IN)
        houstonService.canUpdateGcmToken = false
        subject.run(token: fakeToken)

        //stop failure mode due to timer tic
        subscribeTo(subject.getValue(),
                    onSuccess: { self.expectation?.fulfill() },
                    onError: { error in XCTFail() })

        houstonService.canUpdateGcmToken = true
        timer.tic()

        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(self.preferences.string(forKey: .gcmToken), self.fakeToken)
            XCTAssertEqual(self.houstonService.updateGcmTokenCalledCount, 2)
            XCTAssertEqual(self.timer.stopCalledCount, 2)
            XCTAssertTrue(self.preferences.bool(forKey: .gcmTokenSynced))
        }
    }

    // This is actually executed by the taskRunner.
    func test_runOnStartup() {
        houstonService.updateGcmTokenExpectation = expectation(description: "Wait for houston to be called twice")

        sessionRepository.setStatus(.LOGGED_IN)
        preferences.set(value: secondFakeToken, forKey: .gcmToken)

        subject.run()

        waitForExpectations(timeout: 3.0) { _ in
            XCTAssertEqual(self.preferences.string(forKey: .gcmToken), self.secondFakeToken)
            XCTAssertEqual(self.houstonService.updateGcmTokenCalledCount, 1)
            XCTAssertEqual(self.timer.stopCalledCount, 1)
            XCTAssertEqual(self.houstonService.lastSyncedGCMToken, self.secondFakeToken)
            XCTAssertTrue(self.preferences.bool(forKey: .gcmTokenSynced))
        }
    }
}
