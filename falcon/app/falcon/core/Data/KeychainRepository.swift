//
//  KeychainRepository.swift
//
//  Created by Lucas Serruya on 02/02/2023.
//

import Foundation

public class KeychainRepository {
    private let keyPrefix: String
    private let group: String

    // swiftlint:disable type_name
    public enum storedKeys: String, CaseIterable {
        case deviceCheckToken
        case fallbackDeviceToken
    }

    init(keyPrefix: String = Identifiers.bundleId,
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
        // swiftlint disable: forbidden_raw_keychain_calls
        let query = buildQuery(for: key, forInsert: false)
        // swiftlint:disable forbidden_raw_keychain_calls
        SecItemDelete(query as CFDictionary)
        // swiftlint:enable forbidden_raw_keychain_calls
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
        // swiftlint:disable forbidden_raw_keychain_calls
        var status = SecItemUpdate(query as CFDictionary, toSet as CFDictionary)
        if status == errSecItemNotFound {
            let addQuery = query.merging(toSet) { (k, _) in k }
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }
        // swiftlint:enable forbidden_raw_keychain_calls

        guard status == errSecSuccess else {
            throw MuunError(SecureStorage.Errors.secureStorageError)
        }
    }

    public func get(_ key: String) throws -> String {

        var query = buildQuery(for: key, forInsert: false)
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        // swiftlint:disable forbidden_raw_keychain_calls
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        // swiftlint:enable forbidden_raw_keychain_calls

        guard status == errSecSuccess,
            let value = item as? Data else {
            throw MuunError(SecureStorage.Errors.secureStorageError)
        }

        guard let ret = String(data: value, encoding: .utf8) else {
            throw MuunError(SecureStorage.Errors.invalidData)
        }

        return ret
    }

    func has(_ key: String) throws -> Bool {

        let query = buildQuery(for: key, forInsert: false)
        // swiftlint:disable forbidden_raw_keychain_calls
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        // swiftlint:enable forbidden_raw_keychain_calls

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw MuunError(SecureStorage.Errors.secureStorageError)
        }

        return status == errSecSuccess
    }

    func wipe(preservePin: Bool = false) {
        var keychainStoredKeys = getKeychainStoredKeys()

        if preservePin {
            do {
                keychainStoredKeys[SecureStorage.Keys.pin.rawValue] = try get(SecureStorage.Keys.pin.rawValue)
            } catch {
                Logger.log(error: error)
            }
        }

        let dict: [NSString: Any] = [kSecClass: kSecClassGenericPassword,
                                     kSecAttrService: keyPrefix,
                                     kSecAttrAccessGroup: group]

        // swiftlint:disable forbidden_raw_keychain_calls
        let result = SecItemDelete(dict as CFDictionary)
        // swiftlint:enable forbidden_raw_keychain_calls

        if result != noErr && result != errSecItemNotFound {
            Logger.log(error: NSError(domain: "wipe_secure_storage_failed", code: Int(result)))
            // What should we do here? deletion may fail and users will have
        }

        keychainStoredKeys.forEach {
            do {
                try self.store($0.value, at: $0.key)
            } catch {
                Logger.log(error: error)
            }
        }
    }

    private func getKeychainStoredKeys() -> [String: String] {
        return storedKeys.allCases.reduce(into: [String: String]()) {
            do {
                $0[$1.rawValue] = try get($1.rawValue)
            } catch {
                Logger.log(error: error)
            }
        }
    }
}
