//
//  StoreKeySetAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 10/09/2020.
//

import Foundation
import RxSwift

public class StoreKeySetAction: AsyncAction<()> {

    private let keysRepository: KeysRepository

    init(keysRepository: KeysRepository) {
        self.keysRepository = keysRepository

        super.init(name: "StoreKeySetAction")
    }

    public func run(keySet: KeySet, userInput: String) {

        do {
            if let muunKey = keySet.muunKey {
                try self.keysRepository.store(muunPrivateKey: muunKey)
            }

            for key in keySet.challengeKeys {
                try self.keysRepository.store(challengeKey: key)
            }

            let privateKey = try KeyCrypter.decrypt(keySet.encryptedPrivateKey, passphrase: userInput)
            let derivedKey = try privateKey.derive(to: .base)

            try self.keysRepository.store(key: derivedKey)
        } catch {
            Logger.fatal(error: error)
        }

    }
}
