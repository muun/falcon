//
//  SecureStorage.swift
//  falcon
//
//  Created by Juan Pablo Civile on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

class SecureStorage {

    enum Errors: Error {
        case secureStorageError
        case invalidData
    }

    enum Keys: String, CaseIterable {
        case privateKey
        case muunPrivateKey
        case pin
        case authToken
        case pinAttemptsLeft
        case passwordSalt
        case recoveryCodeSalt
        case passwordPublicKey
        case recoveryCodePublicKey
    }

    private let keyPrefix: String
    private let group: String

    public init(keyPrefix: String, group: String) {
        self.keyPrefix = keyPrefix
        self.group = group
    }

    private func tagFrom(key: Keys) -> Data {
        return (keyPrefix + "." + key.rawValue).data(using: .utf8)!
    }

    private func buildQuery(for key: Keys, forInsert: Bool) -> [String: Any] {
        let scopedKey = tagFrom(key: key)
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrGeneric as String: scopedKey,
                                    kSecAttrAccount as String: scopedKey,
                                    kSecAttrService as String: keyPrefix,
                                    kSecAttrAccessGroup as String: group]

        if forInsert {
            query[kSecAttrSynchronizable as String] = false
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAlwaysThisDeviceOnly
        }

        return query
    }

    func wipeAll() {
        for key in Keys.allCases {
            delete(key)
        }
    }

    func delete(_ key: Keys) {
        let query = buildQuery(for: key, forInsert: false)
        SecItemDelete(query as CFDictionary)
    }

    func store(_ string: String, at key: Keys) throws {

        /*
         https://developer.apple.com/documentation/security/keychain_services/
         keychain_itemsrestricting_keychain_item_accessibility
        */

        let data = string.data(using: .utf8, allowLossyConversion: true)

        let query = buildQuery(for: key, forInsert: true)
        let toSet = [kSecValueData as String: data!]

        // We first try to update it, and if we fail we store it
        var status = SecItemUpdate(query as CFDictionary, toSet as CFDictionary)
        if status == errSecItemNotFound {
            let addQuery = query.merging(toSet) { (k, _) in k }
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }

        guard status == errSecSuccess else {
            throw MuunError(Errors.secureStorageError)
        }
    }

    func get(_ key: Keys) throws -> String {

        var query = buildQuery(for: key, forInsert: false)
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
            let value = item as? Data else {
                throw MuunError(Errors.secureStorageError)
        }

        guard let ret = String(data: value, encoding: .utf8) else {
            throw MuunError(Errors.invalidData)
        }

        return ret
    }

    func has(_ key: Keys) throws -> Bool {

        let query = buildQuery(for: key, forInsert: false)
        let status = SecItemCopyMatching(query as CFDictionary, nil)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw MuunError(Errors.secureStorageError)
        }

        return status == errSecSuccess
    }
}
