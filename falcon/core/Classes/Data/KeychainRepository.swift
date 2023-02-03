//
//  KeychainRepository.swift
//  core-all
//
//  Created by Lucas Serruya on 02/02/2023.
//

import Foundation

public class KeychainRepository {
    private let keyPrefix: String
    private let group: String
    
    public enum storedKeys: String {
        case deviceCheckToken
    }
    
    enum Errors: Error {
        case KeychainRepositoryError
        case invalidData
    }

    public init(keyPrefix: String = Identifiers.bundleId,
                group: String = Identifiers.group) {
        self.keyPrefix = keyPrefix
        self.group = group
    }

    private func tagFrom(key: String) -> Data {
        return (keyPrefix + "." + key).data(using: .utf8)!
    }

    private func buildQuery(for key: String, forInsert: Bool) -> [String: Any] {
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

    public func delete(_ key: String) {
        let query = buildQuery(for: key, forInsert: false)
        SecItemDelete(query as CFDictionary)
    }

    public func store(_ string: String, at key: String) throws {

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
            throw MuunError(Errors.KeychainRepositoryError)
        }
    }

    public func get(_ key: String) throws -> String {

        var query = buildQuery(for: key, forInsert: false)
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
            let value = item as? Data else {
                throw MuunError(Errors.KeychainRepositoryError)
        }

        guard let ret = String(data: value, encoding: .utf8) else {
            throw MuunError(Errors.invalidData)
        }

        return ret
    }
}
