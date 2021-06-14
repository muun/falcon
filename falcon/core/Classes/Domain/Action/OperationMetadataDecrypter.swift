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

        let metadata: String
        let decrypter: LibwalletDecrypterProtocol

        if let sender = operation.senderMetadata {
            metadata = sender
            decrypter = try keysRepository.getBasePrivateKey().decrypter()

        } else if let receiver = operation.receiverMetadata {
            // TODO: Eventually extract the public key from a known place
            metadata = receiver
            decrypter = try keysRepository.getBasePrivateKey().decrypter(from: nil)

        } else {
            return nil
        }

        return JSONDecoder.model(from: try decrypter.decrypt(metadata))
    }

    func decrypt(metadata: String) throws -> OperationMetadataJson? {
        let decrypter = try keysRepository.getBasePrivateKey().decrypter()
        return JSONDecoder.model(from: try decrypter.decrypt(metadata))
    }

}
