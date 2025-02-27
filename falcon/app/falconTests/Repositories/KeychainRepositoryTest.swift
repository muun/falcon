//
//  KeychainRepositoryTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 03/11/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import XCTest
@testable import Muun

class KeychainRepositoryTest: MuunTestCase {
    lazy var keychainRepository: KeychainRepository = resolve()
    lazy var secureStorage: SecureStorage = resolve()

    let deviceCheckTokenKey = KeychainRepository.storedKeys.deviceCheckToken.rawValue
    let passwordPublicKeyValue = "passwordPublicKeyValue"
    let deviceCheckTokenValue = "deviceCheckTokenValue"
    let unknownKey = "unknownKey"
    let unknownValue = "unknownValue"

    func test_keyLifeCycle() {
        try! keychainRepository.store(deviceCheckTokenValue, at: deviceCheckTokenKey)
        try! secureStorage.store(passwordPublicKeyValue, at: .passwordPublicKey)

        XCTAssertTrue(try! keychainRepository.has(deviceCheckTokenKey))
        XCTAssertEqual(try! keychainRepository.get(deviceCheckTokenKey),
                       deviceCheckTokenValue)
        XCTAssertTrue(try! secureStorage.has(.passwordPublicKey))
        XCTAssertEqual(try! secureStorage.get(.passwordPublicKey), passwordPublicKeyValue)

        keychainRepository.delete(deviceCheckTokenKey)
        secureStorage.delete(.passwordPublicKey)

        XCTAssertFalse(try! keychainRepository.has(deviceCheckTokenKey))
        XCTAssertNil(try? keychainRepository.get(deviceCheckTokenKey))
        XCTAssertFalse(try! secureStorage.has(.passwordPublicKey))
        XCTAssertNil(try? secureStorage.get(.passwordPublicKey))

    }

    func test_wipeSecureStorageAndUnknownKeepKeychainKeys() {
        try! secureStorage.store(passwordPublicKeyValue, at: .passwordPublicKey)
        try! keychainRepository.store(deviceCheckTokenValue, at: deviceCheckTokenKey)
        // Unknown key to be wiped
        try! keychainRepository.store(unknownValue, at: unknownKey)

        keychainRepository.wipe()

        XCTAssertNil(try? secureStorage.get(.passwordPublicKey))
        XCTAssertNil(try? keychainRepository.get(unknownKey))
        XCTAssertEqual(try! keychainRepository.get(deviceCheckTokenKey),
                       deviceCheckTokenValue)
    }
}
