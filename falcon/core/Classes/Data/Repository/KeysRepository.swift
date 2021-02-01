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
    private let userRepository: UserRepository

    init(preferences: Preferences, secureStorage: SecureStorage, userRepository: UserRepository) {
        self.preferences = preferences
        self.secureStorage = secureStorage
        self.userRepository = userRepository
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

        try secureStorage.store(key.path, at: .baseKeyDerivationPath)
        try secureStorage.store(encodedKey, at: .privateKey)

        preferences.set(
            value: key.walletPublicKey().fingerprint.toHexString(),
            forKey: .userKeyFingerprint
        )
    }

    func getBasePrivateKey() throws -> WalletPrivateKey {

        let privateKey = try secureStorage.get(.privateKey)
        let path = try secureStorage.get(.baseKeyDerivationPath)

        return WalletPrivateKey.fromBase58(privateKey, on: path)
    }

    func getBasePublicKey() throws -> WalletPublicKey {
        return try getBasePrivateKey().walletPublicKey()
    }

    func store(cosigningKey: WalletPublicKey) {
        preferences.set(value: cosigningKey.toBase58(), forKey: .muunPublicKey)
        preferences.set(value: cosigningKey.path, forKey: .muunPublicKeyPath)
        preferences.set(value: cosigningKey.fingerprint.toHexString(), forKey: .muunKeyFingerprint)
    }

    func store(swapServerKey: WalletPublicKey) {
        preferences.set(value: swapServerKey.toBase58(), forKey: .swapServerPublicKey)
        preferences.set(value: swapServerKey.path, forKey: .swapServerPublicKeyPath)
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

    func getMuunPrivateKey() throws -> String {
        return try secureStorage.get(.muunPrivateKey)
    }

    func store(muunKeyFingerprint: String) {
        preferences.set(value: muunKeyFingerprint, forKey: .muunKeyFingerprint)
    }

    func getMuunKeyFingerprint() throws -> String {
        guard let fingerprint = preferences.string(forKey: .muunKeyFingerprint) else {
            throw MuunError(KeyStorageError.missingKey)
        }
        return fingerprint
    }

    func store(userKeyFingerprint: String) {
        preferences.set(value: userKeyFingerprint, forKey: .userKeyFingerprint)
    }

    func getUserKeyFingerprint() throws -> String {
        guard let fingerprint = preferences.string(forKey: .userKeyFingerprint) else {
            throw MuunError(KeyStorageError.missingKey)
        }
        return fingerprint
    }

    private func saltKey(for type: ChallengeType) -> SecureStorage.Keys {

        switch type {
        case .PASSWORD:
            return .passwordSalt
        case .RECOVERY_CODE:
            return .recoveryCodeSalt
        case .USER_KEY:
            Logger.fatal(error: MuunError(KeyStorageError.noSaltForUserKey))
        }
    }

    private func publicKeyKey(for type: ChallengeType) -> SecureStorage.Keys {

        switch type {
        case .PASSWORD:
            return .passwordPublicKey
        case .RECOVERY_CODE:
            return .recoveryCodePublicKey
        case .USER_KEY:
            return .userKeyPublicKey
        }
    }

    private func challengeVersionKey(for type: ChallengeType) -> SecureStorage.Keys {

        switch type {
        case .PASSWORD:
            return .passwordVersionKey
        case .RECOVERY_CODE:
            return .recoveryCodeVersionKey
        case .USER_KEY:
            return .userVersionKey
        }
    }

    func store(challengeKey: ChallengeKey) throws {
        let type = challengeKey.type
        if let salt = challengeKey.salt {
            try secureStorage.store(salt.toHexString(), at: saltKey(for: type))
        }
        try secureStorage.store(challengeKey.publicKey.toHexString(), at: publicKeyKey(for: type))
        try secureStorage.store(
            String(describing: challengeKey.getChallengeVersion()),
            at: challengeVersionKey(for: type)
        )

        if var user = userRepository.getUser() {
            if type == .RECOVERY_CODE {
                user.hasRecoveryCodeChallengeKey = true
                preferences.set(value: true, forKey: .hasRecoveryCode)
            } else if type == .PASSWORD {
                user.hasPasswordChallengeKey = true
            }
            userRepository.setUser(user)
        }
    }

    func hasChallengeKey(type: ChallengeType) throws -> Bool {
        return try secureStorage.has(publicKeyKey(for: type))
    }

    func getChallengeKey(with type: ChallengeType) throws -> ChallengeKey {

        let saltHex: String? = try? secureStorage.get(saltKey(for: type))
        let salt: Data? = (saltHex != nil)
            ? Data(hex: saltHex!)
            : nil

        return ChallengeKey(
            type: type,
            publicKey: Data(hex: try secureStorage.get(publicKeyKey(for: type))),
            salt: salt,
            challengeVersion: Int(try secureStorage.get(challengeVersionKey(for: type)))
        )
    }

}

enum KeyStorageError: Error {
    case secureStorageError
    case missingKey
    case noSaltForUserKey
}
