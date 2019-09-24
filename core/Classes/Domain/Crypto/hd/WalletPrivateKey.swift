//
//  WalletPrivateKey.swift
//  falcon
//
//  Created by Manu Herrera on 07/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet

public struct WalletPrivateKey {

    let key: LibwalletHDPrivateKey

    public init(_ hdPrivateKey: LibwalletHDPrivateKey) {
        self.key = hdPrivateKey
    }

    var path: String {
        return key.path
    }

    func walletPublicKey() -> WalletPublicKey {
        return WalletPublicKey(key.publicKey()!)
    }
}

extension WalletPrivateKey {

    static func createRandom() -> WalletPrivateKey {

        let key = LibwalletHDPrivateKey(
            Data(bytes: Hashes.randomBytes(count: 32)),
            network: Environment.current.network
        )!

        return WalletPrivateKey(key)
    }

    public func toBase58() -> String {
        return key.string()
    }

    static func fromBase58(_ str: String, on path: String) -> WalletPrivateKey {
        let key = LibwalletHDPrivateKey(from: str, path: path)!
        return WalletPrivateKey(key)
    }

}

extension WalletPrivateKey {

    func derive(to newPath: String) throws -> WalletPrivateKey {
        return WalletPrivateKey(try key.derive(to: newPath))
    }

    func derive(to schema: DerivationSchema) throws -> WalletPrivateKey {
        return try derive(to: schema.path)
    }

}

extension WalletPrivateKey: Equatable {

    public static func == (lhs: WalletPrivateKey, rhs: WalletPrivateKey) -> Bool {
        return lhs.toBase58() == rhs.toBase58() && lhs.key.path == rhs.key.path
    }

}
