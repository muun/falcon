//
//  KeyCrypterTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 18/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import XCTest

@testable import Muun

class KeyCrypterTests: XCTestCase {

    var key: WalletPrivateKey!
    let password = "asdasdasd"

    override func setUp() {
        key = WalletPrivateKey.createRandom()
    }
    
    func testEncrypt() {
        // This test simply checks we don't throw fatal errors
        _ = KeyCrypter.encrypt(key, passphrase: password)
    }
    
    func testEncryptDecrypt() {
        let encrypted = KeyCrypter.encrypt(key, passphrase: password)
        XCTAssertEqual(try KeyCrypter.decrypt(encrypted, passphrase: password), key)
    }
    
    func testInvalidPassphrase() throws {
        let encrypted = KeyCrypter.encrypt(key, passphrase: password)
        XCTAssertThrowsError(try KeyCrypter.decrypt(encrypted, passphrase: password + "foo"))
    }
    
}
