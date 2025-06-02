//
//  WalletPublicKey.swift
//  falcon
//
//  Created by Juan Pablo Civile on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet

public struct WalletPublicKey {
    let key: LibwalletHDPublicKey

    public init(_ key: LibwalletHDPublicKey) {
        self.key = key
    }

    var path: String {
        return key.path
    }

    var fingerprint: Data {
        return key.fingerprint()!
    }
}

extension WalletPublicKey {

    public func toBase58() -> String {
        return key.string()
    }

    static func fromBase58(_ str: String, on path: String) -> WalletPublicKey {

        let key = LibwalletHDPublicKey(from: str, path: path, network: Environment.current.network)!

        return WalletPublicKey(key)
    }
}

extension WalletPublicKey {

    func derive(at index: UInt32) throws -> WalletPublicKey {
        return WalletPublicKey(try key.derived(at: Int64(index)))
    }

    func derive(to newPath: String) throws -> WalletPublicKey {
        return WalletPublicKey(try key.derive(to: newPath))
    }

    func derive(to schema: DerivationSchema) throws -> WalletPublicKey {

        return try derive(to: schema.path)
    }

}

extension WalletPublicKey: Equatable {

    public static func == (lhs: WalletPublicKey, rhs: WalletPublicKey) -> Bool {
        // This is rather dumb way to implement this, but BitcoinKit doesnt allow for more
        return lhs.toBase58() == rhs.toBase58() && lhs.key.path == rhs.key.path
    }

}

// Remove when delete security cards POC
extension WalletPublicKey {
    func serializeUncompressed() -> Data? {
        key.serializeUncompressed()
    }
}
