//
//  Untitled.swift
//  falcon
//
//  Created by Juan Pablo Civile on 26/02/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Libwallet

class KeyProvider: NSObject, App_provided_dataKeyProviderProtocol {

    private let keysRepository: KeysRepository

    init(keysRepository: KeysRepository) {
        self.keysRepository = keysRepository
    }

    func fetchUserKey() throws -> App_provided_dataKeyData {
        let userKey = try keysRepository.getBasePrivateKey()

        let keyData = App_provided_dataKeyData()
        keyData.serialized = userKey.toBase58()
        keyData.path = userKey.path
        return keyData
    }

    func fetchMuunKey() throws -> App_provided_dataKeyData {
        let muunKey = try keysRepository.getCosigningKey()

        let keyData = App_provided_dataKeyData()
        keyData.serialized = muunKey.toBase58()
        keyData.path = muunKey.path
        return keyData
    }

    func fetchMaxDerivedIndex() -> Int {
        return keysRepository.getMaxWatchingIndex()
    }

}
