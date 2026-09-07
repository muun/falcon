//
//  LibwalletSecureKeyValueStorage.swift
//  falcon
//

import Foundation
import Libwallet

class LibwalletSecureKeyValueStorage: NSObject, App_provided_dataSecureKeyValueStorageProtocol {

    // TODO: KeychainRepository is legacy and is going to be migrated
    // in a future modernization.
    private let keychainRepository: KeychainRepository

    init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    func put(_ key: String?, value: Data?) throws -> App_provided_dataSecureKvResponse {
        guard let key, let value else {
            fatalError("key and value can't be nil")
        }
        let response = App_provided_dataSecureKvResponse()
        response.statusCode = performPut(key: key, value: value)
        return response
    }

    func get(_ key: String?) throws -> App_provided_dataSecureKvGetResponse {
        guard let key else {
            fatalError("key can't be nil")
        }
        let (value, statusCode) = performGet(key: key)
        let response = App_provided_dataSecureKvGetResponse()
        response.value = value
        response.statusCode = statusCode
        return response
    }

    func delete(_ key: String?) throws -> App_provided_dataSecureKvResponse {
        guard let key else {
            fatalError("key can't be nil")
        }
        let response = App_provided_dataSecureKvResponse()
        response.statusCode = performDelete(key: key)
        return response
    }

    func wipe() throws -> App_provided_dataSecureKvResponse {
        let response = App_provided_dataSecureKvResponse()
        response.statusCode = performWipe()
        return response
    }

    private func performPut(key: String, value: Data) -> Int32 {
        do {
            try keychainRepository.store(value, at: key)
            return App_provided_dataSecureKvStatusOk
        } catch {
            Logger.log(error: error)
            return App_provided_dataSecureKvStatusStorageFailed
        }
    }

    // The value is returned up the stack, never held in a field: plaintext
    // only lives in the transient frame while the bridge builds its response.
    private func performGet(key: String) -> (Data, Int32) {
        do {
            let value = try keychainRepository.getData(key)
            return (value, App_provided_dataSecureKvStatusOk)
        } catch let error as MuunError
            where error.kind as? SecureStorage.Errors == .itemNotFound {
            // The keychain surfaces "missing" distinctly; every other read
            // failure collapses to StorageFailed, as iOS has no observable
            // decryption-failed state at this layer.
            return (Data(), App_provided_dataSecureKvStatusNotFound)
        } catch {
            Logger.log(error: error)
            return (Data(), App_provided_dataSecureKvStatusStorageFailed)
        }
    }

    private func performDelete(key: String) -> Int32 {
        do {
            try keychainRepository.deleteChecked(key)
            return App_provided_dataSecureKvStatusOk
        } catch {
            Logger.log(error: error)
            return App_provided_dataSecureKvStatusStorageFailed
        }
    }

    private func performWipe() -> Int32 {
        // KeychainRepository.wipe() is void; SecItemDelete failures are logged
        // internally, so there is no observable StorageFailed path here.
        keychainRepository.wipe()
        return App_provided_dataSecureKvStatusOk
    }
}
