//
//  DeviceCheckTokenProviderTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 29/10/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import XCTest
@testable import core

class DeviceCheckTokenProviderTest: MuunTestCase {
    let deviceCheckAdapter = DeviceCheckAdapterSpy()
    let timer = MUTimerFake()
    private let refreshTimeInSedonds: TimeInterval = 60;
    private let paranoidRefreshTimeInSedonds: TimeInterval = 10;
    private let successfullToken = "thisIsTheFirstTokek="
    private let secondSuccessfullToken = "thisIsTheSecondToken"
    lazy var provider = DeviceCheckTokenProvider(deviceCheckAdapter: deviceCheckAdapter,
                                                 timer: timer)

    func test_start_notSupported_DoesNothing() {
        deviceCheckAdapter.isSupportedExpected = false

        provider.start()

        XCTAssertEqual(deviceCheckAdapter.generateTokenCalledCount, 0)
        XCTAssertEqual(timer.stopCalledCount, 0)
        XCTAssertEqual(timer.startCalledCount, 0)
    }

    func test_refreshFlow() {
        deviceCheckAdapter.tokenExpected = successfullToken

        provider.start()

        // Rate limtied provides among timer tics
        XCTAssertEqual(successfullToken, provider.provide(ignoreRateLimit: false))
        // Rate limit reached
        XCTAssertNil(provider.provide(ignoreRateLimit: false))
        // Forcing rate limit
        XCTAssertEqual(successfullToken, provider.provide(ignoreRateLimit: true))
        deviceCheckAdapter.tokenExpected = secondSuccessfullToken
        timer.tic()
        // After tic value is available again
        XCTAssertEqual(secondSuccessfullToken, provider.provide(ignoreRateLimit: false))
        //1 call after start and anotherone after
        XCTAssertEqual(deviceCheckAdapter.generateTokenCalledCount, 2)
        XCTAssertEqual(timer.stopCalledCount, 1)
        XCTAssertEqual(timer.startCalledCount, 1)
        XCTAssertEqual(timer.timeInterval, refreshTimeInSedonds)
    }

    func test_checkTokenFailsButThereWereATokenProvidedBefore() {
        deviceCheckAdapter.tokenExpected = successfullToken

        provider.start()

        XCTAssertEqual(successfullToken, provider.provide(ignoreRateLimit: false))

        deviceCheckAdapter.tokenExpected = nil
        timer.tic()
        XCTAssertEqual(deviceCheckAdapter.generateTokenCalledCount, 2)
        // No token was provided but we have a previous token reported.
        XCTAssertEqual(timer.timeInterval, refreshTimeInSedonds)
    }

    func test_checkTokenFailsAndNeverSucceed() {
        deviceCheckAdapter.tokenExpected = nil
        putTimerInNormalMode()

        provider.start()

        XCTAssertEqual(deviceCheckAdapter.generateTokenCalledCount, 1)
        // we entered in paranoid mode because of failure
        XCTAssertEqual(timer.timeInterval, paranoidRefreshTimeInSedonds)
    }

    func test_reactToForeground_NotInParanoidMode() {
        putTimerInNormalMode()

        provider.reactToForegroundAppState()

        XCTAssertEqual(deviceCheckAdapter.isSupportedCalledCount, 0)
    }

    func test_reactToForeground_InParanoidMode() {
        putTimerInParanoidMode()
        deviceCheckAdapter.tokenExpected = successfullToken

        provider.reactToForegroundAppState()

        // After reaction we have ask for the token again
        XCTAssertEqual(successfullToken, provider.provide(ignoreRateLimit: false))
        // After a success we're in normal mode again
        XCTAssertEqual(timer.currentTimeInterval, refreshTimeInSedonds)
    }

    func test_reactToRequestSucceedOnlyOnce() {
        putTimerInParanoidMode()
        deviceCheckAdapter.tokenExpected = nil

        provider.reactToRequestSucceded()

        // After reaction we have ask for the token again but it failed
        XCTAssertNil(provider.provide(ignoreRateLimit: false))
        XCTAssertEqual(timer.currentTimeInterval, paranoidRefreshTimeInSedonds)

        provider.reactToRequestSucceded()

        XCTAssertEqual(deviceCheckAdapter.isSupportedCalledCount, 1)
    }

    func test_reactToRequestSucceed_notInParanoidMode() {
        putTimerInNormalMode()

        provider.reactToRequestSucceded()

        XCTAssertEqual(deviceCheckAdapter.isSupportedCalledCount, 0)
    }

    private func putTimerInParanoidMode() {
        timer.currentTimeInterval = paranoidRefreshTimeInSedonds
    }

    private func putTimerInNormalMode() {
        timer.currentTimeInterval = refreshTimeInSedonds
    }
}


class MUTimerFake: MUTimer {
    var currentTimeInterval: TimeInterval = 1
    var stopCalledCount = 0
    var startCalledCount = 0
    var ticSelector: Selector?
    var ticTarget: AnyObject?

    override init() {
        super.init()
    }

    override var timeInterval: TimeInterval {
        return currentTimeInterval
    }

    override func stop() {
        stopCalledCount += 1
    }

    func tic() {
        _ = ticTarget?.perform(ticSelector)
    }

    override func start(timeInterval: TimeInterval,
                        target: Any,
                        selector: Selector,
                        repeats: Bool) {
        startCalledCount += 1
        currentTimeInterval = timeInterval
        ticSelector = selector
        ticTarget = target as AnyObject
    }
}

class DeviceCheckAdapterSpy: DeviceCheckAdapter {
    var isSupportedExpected = true
    var isSupportedCalledCount = 0
    var generateTokenCalledCount = 0
    var tokenExpected: String?

    func generateToken(completionHandler completion: @escaping (Data?, Error?) -> Void) {
        generateTokenCalledCount += 1
        var tokenAsData: Data?
        if let tokenExpected = tokenExpected,
           let tokenAsBase64 = Data(base64Encoded: tokenExpected) {
            tokenAsData = tokenAsBase64
        }

        completion(tokenAsData, nil)
    }

    func isSupported() -> Bool {
        isSupportedCalledCount += 1
        return isSupportedExpected
    }
}
