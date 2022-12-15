//
//  UserPreferencesRepositoryTest.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 11/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
@testable import core

class UpdateUserPreferencesActionTest: MuunTestCase {

    fileprivate var repository: UserPreferencesRepository!
    fileprivate var action: UpdateUserPreferencesAction!
    fileprivate var preferences: Preferences!
    fileprivate var fakeHoustonService: FakeHoustonService!

    override func setUp() {
        super.setUp()

        fakeHoustonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)

        preferences = resolve()
        action = resolve()
        repository = resolve()
    }

    func testDefaultValues() throws {
        let prefs = get()

        XCTAssertFalse(prefs.seenNewHome)
        XCTAssertFalse(prefs.receiveStrictMode)
    }

    func testUpdate() throws {
        let prefs = get()

        XCTAssertFalse(prefs.receiveStrictMode)

        action.run {
            return $0.copy(receiveStrictMode: true)
        }

        let updatedPrefs = try action.getValue()
            .map { _ in self.get() }
            .toBlocking()
            .first()!

        XCTAssertTrue(updatedPrefs.receiveStrictMode)
        XCTAssertEqual(updatedPrefs.seenNewHome, prefs.seenNewHome)
        XCTAssertEqual(fakeHoustonService.calls, 1)
    }

    private func get() -> UserPreferences {
        return try! repository.watch()
            .toBlocking()
            .first()!
    }
}
