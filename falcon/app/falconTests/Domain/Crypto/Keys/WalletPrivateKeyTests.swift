//
//  WalletPrivateKeyTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import XCTest

@testable import Muun

class WalletPrivateKeyTests: XCTestCase {

    func testRandomKeySerialization() {
        let key = WalletPrivateKey.createRandom()
        
        let serialized = key.toBase58()
        let deserialized = WalletPrivateKey.fromBase58(serialized, on: "m")
        
        // Of course, Bitcoin Kit doesn't support HD key equality, so we test against serialization
        XCTAssert(serialized == deserialized.toBase58())
    }

    func testDerivedSerialization() throws {

        let root = WalletPrivateKey.fromBase58("tprv8ZgxMBicQKsPdGCzsJ31BsQnFL1TSQ82dfsZYTtsWJ1T8g7xTfnV19gf8nYPqzkzk6yLL9kzDYshmUrYyXt7uXsGbk9eN7juRxg9sjaxSjn", on: "m")

        let base = try root.derive(to: .base)

        XCTAssertEqual(base.toBase58(), "tprv8e8vMhwEcLr1ZfZETKTQSpxJ6KfZuczALe8KrRCDLpSbXPwp7PY1ZVHtqUkFsYZETPRcfjVSCv8DiYP9RyAZrFhnLE8aYdaSaZEWyT5c8Ji")

        let str = "tprv8e8vMhwEcLr1ZfZETKTQSpxJ6KfZuczALe8KrRCDLpSbXPwp7PY1ZVHtqUkFsYZETPRcfjVSCv8DiYP9RyAZrFhnLE8aYdaSaZEWyT5c8Ji"
        let decoded = WalletPrivateKey.fromBase58(str, on: DerivationSchema.base.path)

        XCTAssertEqual(decoded.toBase58(), str)
    }
}
