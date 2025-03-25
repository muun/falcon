//
//  SecureStorage.swift
//  falcon
//
//  Created by Juan Pablo Civile on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public class SecureStorage {

    enum Errors: Error {
        case secureStorageError
        case invalidData
    }

    enum Keys: String, CaseIterable {
        case privateKey
        case encriptedUserPrivateKey
        case muunPrivateKey
        case baseKeyDerivationPath
        case pin
        case authToken
        case pinAttemptsLeft
        case passwordSalt
        case recoveryCodeSalt
        case passwordPublicKey
        case recoveryCodePublicKey
        case userKeyPublicKey
        case passwordVersionKey
        case recoveryCodeVersionKey
        case userVersionKey
    }

    private let keychainRepository: KeychainRepository

    public init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    func wipeAll() {
        keychainRepository.wipe()
    }

    func delete(_ key: Keys) {
        keychainRepository.delete(key.rawValue)
    }

    func store(_ string: String, at key: Keys) throws {
        try keychainRepository.store(string, at: key.rawValue)
    }

    func get(_ key: Keys) throws -> String {
        return try keychainRepository.get(key.rawValue)
    }

    func has(_ key: Keys) throws -> Bool {
        return try keychainRepository.has(key.rawValue)
    }
}
