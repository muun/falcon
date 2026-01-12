//
//  ApiReachabiltiyServiceTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 30/10/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import XCTest

@testable import Muun

class ApiReachabiltiyServiceTest: MuunTestCase {
    var reachabilityService: ReachabilityService!
    var houstonService: FakeHoustonService!
    var pingService: FakePingURLService!
    lazy var featureFlagsRepository: FeatureFlagsRepository = resolve()
    lazy var reachabilityStatusRepository: ReachabilityStatusRepository = resolve()
    lazy var sessionRepository: SessionRepository = resolve()

    override func setUp() {
        super.setUp()

        pingService = replace(.singleton, PingURLService.self, FakePingURLService.init)
        houstonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        reachabilityService = replace(.singleton, ReachabilityService.self) {
            ApiReachabilityClient(sessionActions: $0,
                                   flagsRepository: $1,
                                   reachabilityStatusRepository: $2,
                                   pingService: $3) as ReachabilityService
        }
        (reachabilityService as! ApiReachabilityClient).houstonService = houstonService
    }

    func test_fallInFallbackLoggedIn_NothingHappens() {
        sessionRepository.setStatus(.LOGGED_IN)

        reachabilityService.collectReachabilityStatusIfNeeded()

        XCTAssertEqual(houstonService.canReachServerCalledCount, 0)
        XCTAssertEqual(pingService.runCalledCount, 0)
    }

    func test_fallInFallbackNotLoggedIn_onlyHoustonReachable() {
        sessionRepository.setStatus(.CREATED)
        houstonService.canReachServerExpected = true
        pingService.pingExpected = false

        reachabilityService.collectReachabilityStatusIfNeeded()

        let statusOnRepo = reachabilityStatusRepository.fetch()
        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
        XCTAssertEqual(statusOnRepo?.houston, true)
        XCTAssertEqual(statusOnRepo?.deviceCheck, false)
    }

    func test_fallInFallbackNotLoggedIn_bothServicesReachables() {
        sessionRepository.setStatus(.CREATED)
        houstonService.canReachServerExpected = true
        pingService.pingExpected = true

        reachabilityService.collectReachabilityStatusIfNeeded()

        let statusOnRepo = reachabilityStatusRepository.fetch()
        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
        XCTAssertEqual(statusOnRepo?.houston, true)
        XCTAssertEqual(statusOnRepo?.deviceCheck, true)
    }

    func test_fallInFallbackNotLoggedIn_onlyDeviceCheckReachable() {
        sessionRepository.setStatus(.CREATED)
        houstonService.canReachServerExpected = false
        pingService.pingExpected = true

        reachabilityService.collectReachabilityStatusIfNeeded()

        let statusOnRepo = reachabilityStatusRepository.fetch()
        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
        XCTAssertEqual(statusOnRepo?.houston, false)
        XCTAssertEqual(statusOnRepo?.deviceCheck, true)
    }

    func test_fallInFallbackNotLoggedIn_noReachabilty() {
        sessionRepository.setStatus(.CREATED)
        houstonService.canReachServerExpected = false
        pingService.pingExpected = false

        reachabilityService.collectReachabilityStatusIfNeeded()

        let statusOnRepo = reachabilityStatusRepository.fetch()
        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
        XCTAssertEqual(statusOnRepo?.houston, false)
        XCTAssertEqual(statusOnRepo?.deviceCheck, false)
    }

    func test_dataIsNotGeneratedIfItIsAlreadyCached() {
        sessionRepository.setStatus(.CREATED)
        houstonService.canReachServerExpected = false
        pingService.pingExpected = false

        reachabilityService.collectReachabilityStatusIfNeeded()
        reachabilityService.collectReachabilityStatusIfNeeded()

        let statusOnRepo = reachabilityStatusRepository.fetch()
        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
        XCTAssertEqual(statusOnRepo?.houston, false)
        XCTAssertEqual(statusOnRepo?.deviceCheck, false)
    }

    func test_dataIsProvidedOnlyOnce() {
        sessionRepository.setStatus(.CREATED)
        houstonService.canReachServerExpected = true
        pingService.pingExpected = false

        reachabilityService.collectReachabilityStatusIfNeeded()

        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
        let firstGet = reachabilityService.getReachabilityStatus()
        XCTAssertEqual(firstGet?.houston, true)
        XCTAssertEqual(firstGet?.deviceCheck, false)
        let secondGet = reachabilityService.getReachabilityStatus()
        XCTAssertNil(secondGet)
    }

    func test_flagTurnedOn() {
        sessionRepository.setStatus(.LOGGED_IN)
        houstonService.canReachServerExpected = true
        pingService.pingExpected = false

        featureFlagsRepository.store(flags: [.collectDeviceCheckReachability])

        XCTAssertEqual(houstonService.canReachServerCalledCount, 1)
        XCTAssertEqual(pingService.runCalledCount, 1)
    }
}
