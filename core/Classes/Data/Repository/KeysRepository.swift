//
//  KeysRepository.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

class KeysRepository {

    private let preferences: Preferences
    private let secureStorage: SecureStorage

    init(preferences: Preferences, secureStorage: SecureStorage) {
        self.preferences = preferences
        self.secureStorage = secureStorage
    }

    func updateMaxWatchingIndex(_ index: Int) {
        preferences.set(value: index, forKey: .maxWatchingIndex)
    }

    func updateMaxUsedIndex(_ index: Int) {
        preferences.set(value: index, forKey: .maxUsedIndex)
    }

    func getMaxWatchingIndex() -> Int {
        return preferences.integer(forKey: .maxWatchingIndex)
    }

    func getMaxUsedIndex() -> Int {
        return preferences.integer(forKey: .maxUsedIndex)
    }

    func store(key: WalletPrivateKey) throws {

        let encodedKey = key.toBase58()

        // Restart the usage index
        self.updateMaxUsedIndex(-1)

        preferences.set(value: key.path, forKey: .baseKeyDerivationPath)

        try secureStorage.store(encodedKey, at: .privateKey)
    }

    func getBasePrivateKey() throws -> WalletPrivateKey {

        let privateKey = try self.secureStorage.get(.privateKey)

        guard let path = self.preferences.string(forKey: .baseKeyDerivationPath) else {
            throw MuunError(KeyStorageError.missingKey)
        }

        return WalletPrivateKey.fromBase58(privateKey, on: path)
    }

    func getBasePublicKey() throws -> WalletPublicKey {
        return try getBasePrivateKey().walletPublicKey()
    }

    func store(cosigningKey: WalletPublicKey) {
        preferences.set(value: cosigningKey.toBase58(), forKey: .muunPublicKey)
        preferences.set(value: cosigningKey.path, forKey: .muunPublicKeyPath)
    }

    func getCosigningKey() throws -> WalletPublicKey {
        guard let key = preferences.string(forKey: .muunPublicKey) else {
            throw MuunError(KeyStorageError.missingKey)
        }

        guard let path = preferences.string(forKey: .muunPublicKeyPath) else {
            throw MuunError(KeyStorageError.missingKey)
        }

        return WalletPublicKey.fromBase58(key, on: path)
    }

    func store(muunPrivateKey: String) throws {
        try secureStorage.store(muunPrivateKey, at: .muunPrivateKey)
    }

    private func saltKey(for type: ChallengeType) -> SecureStorage.Keys {

        switch type {
        case .PASSWORD:
            return .passwordSalt
        case .RECOVERY_CODE:
            return .recoveryCodeSalt
        }
    }

    private func publicKeyKey(for type: ChallengeType) -> SecureStorage.Keys {

        switch type {
        case .PASSWORD:
            return .passwordPublicKey
        case .RECOVERY_CODE:
            return .recoveryCodePublicKey
        }
    }

    func store(challengeKey: ChallengeKey, type: ChallengeType) throws {
        try secureStorage.store(challengeKey.salt.toHexString(), at: saltKey(for: type))
        try secureStorage.store(challengeKey.publicKey.toHexString(), at: publicKeyKey(for: type))
        if type == .RECOVERY_CODE {
            preferences.set(value: true, forKey: .hasRecoveryCode)
        }
    }

    func hasChallengeKey(type: ChallengeType) throws -> Bool {
        return try secureStorage.has(saltKey(for: type))
    }

}

enum KeyStorageError: Error {
    case secureStorageError
    case missingKey
}
