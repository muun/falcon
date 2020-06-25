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

    func encrypter() -> LibwalletEncrypterProtocol {
        return key.encrypter()!
    }

    func decrypter() -> LibwalletDecrypterProtocol {
        return key.decrypter()!
    }

    func decrypter(from publicKey: LibwalletPublicKey?) -> LibwalletDecrypterProtocol {
        return key.decrypter(from: publicKey)!
    }
}

extension WalletPrivateKey {

    static func createRandom() -> WalletPrivateKey {

        let key = LibwalletHDPrivateKey(
            Data(Hashes.randomBytes(count: 32)),
            network: Environment.current.network
        )!

        return WalletPrivateKey(key)
    }

    public func toBase58() -> String {
        return key.string()
    }

    static func fromBase58(_ str: String, on path: String) -> WalletPrivateKey {
        let key = LibwalletHDPrivateKey(from: str, path: path, network: Environment.current.network)!
        return WalletPrivateKey(key)
    }

}

extension WalletPrivateKey {

    func deriveRandom() throws -> WalletPrivateKey {
        // In iOS 10+ this generator uses /dev/urandom and is considered crypto safe
        var rng = SystemRandomNumberGenerator()

        // Make sure the upper bit is off cause that means it's hardened
        let childIndex = rng.next(upperBound: UInt32(1) << 31)

        return WalletPrivateKey(try key.derived(at: Int64(childIndex), hardened: false))
    }

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
