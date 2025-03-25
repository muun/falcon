//
//  UserPreferencesRepositoryTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 02/01/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import XCTest
@testable import Muun

class UserPreferencesRepositoryTest: XCTestCase {
    private var repository: UserPreferencesRepository!
    private lazy var preferences = Preferences(userDefaults: UserDefaults.standard)
    private var userPreferencesFromRepository: UserPreferences!

    override func setUp() {
        super.setUp()
        repository = UserPreferencesRepository(preferences: preferences)
    }

    func testWeCanSafelyRemoveUserPreferences() {
        givenAUserPreferencesWithAnExtraValueIsStored()

        whenPreferencesAreRetrieved()

        thenPreferencesWithoutExtraValueAreRetrieved()
    }

    private func givenAUserPreferencesWithAnExtraValueIsStored() {
        let preferencesToStore = StoredUserPreferencesWithAnExtraValue(receiveStrictMode: true,
                                                                       seenNewHome: false,
                                                                       seenLnurlFirstTime: true,
                                                                       defaultAddressType: .taproot,
                                                                       lightningDefaultForReceiving: true,
                                                                       receiveFormatPreference: .UNIFIED)
        preferences.set(object: preferencesToStore, forKey: .userPreferences)
    }

    private func whenPreferencesAreRetrieved(){
        userPreferencesFromRepository = try! repository.watch()
            .toBlocking()
            .first()!
    }

    private func thenPreferencesWithoutExtraValueAreRetrieved() {
        XCTAssertTrue(userPreferencesFromRepository.receiveStrictMode)
        XCTAssertFalse(userPreferencesFromRepository.seenNewHome)
        XCTAssertTrue(userPreferencesFromRepository.seenLnurlFirstTime)
        XCTAssertEqual(userPreferencesFromRepository.defaultAddressType, .taproot)
        XCTAssertEqual(userPreferencesFromRepository.receiveFormatPreference, .UNIFIED)
    }
}

private struct StoredUserPreferencesWithAnExtraValue: Codable {
    var receiveStrictMode: Bool?
    var seenNewHome: Bool?
    var seenLnurlFirstTime: Bool?
    var skippedEmailSetup: Bool?
    var defaultAddressType: AddressType?
    var lightningDefaultForReceiving: Bool?
    var receiveFormatPreference: ReceiveFormatPreference?
}
