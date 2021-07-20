//
//  OperationMetadataDecrypter.swift
//  core
//
//  Created by Juan Pablo Civile on 19/03/2020.
//

import Foundation
import Libwallet

public struct OperationMetadataDecrypter {

    private let keysRepository: KeysRepository

    init(keysRepository: KeysRepository) {
        self.keysRepository = keysRepository
    }

    func decrypt(operation: OperationJson) throws -> OperationMetadataJson? {

        let decrypted: Data

        if let sender = operation.senderMetadata {

            decrypted = try keysRepository.getBasePrivateKey().decrypt(payload: sender)

        } else if let receiver = operation.receiverMetadata {
            // TODO: Eventually extract the public key from a known place
            decrypted = try keysRepository.getBasePrivateKey().decrypt(payload: receiver, from: nil)

        } else {
            return nil
        }

        return JSONDecoder.model(from: decrypted)
    }

    func decrypt(metadata: String) throws -> OperationMetadataJson? {
        let key = try keysRepository.getBasePrivateKey()
        return JSONDecoder.model(from: try key.decrypt(payload: metadata))
    }

}
