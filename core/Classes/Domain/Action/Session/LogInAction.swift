//
//  LogInAction.swift
//  falcon
//
//  Created by Manu Herrera on 19/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet
import RxSwift

public class LogInAction: AsyncAction<KeySet> {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(houstonService: HoustonService, keysRepository: KeysRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository

        super.init(name: "LogInAction")
    }

    public func run(_ challenge: Challenge, userInput: String) {
        let challengePrivateKey = LibwalletChallengePrivateKey(Data(userInput.stringBytes),
                                                               salt: Data(hex: challenge.salt))!

        let single = Single.deferred({
            let signature = try challengePrivateKey.signSha(Data(hex: challenge.challenge))
                return Single.just(ChallengeSignature(type: challenge.type, hex: signature.toHexString()))
            })
            .flatMap({ payload in self.houstonService.logIn(challengeSignature: payload) })
            .do(onSuccess: { keySet in
                if let muunKey = keySet.muunKey {
                    try self.keysRepository.store(muunPrivateKey: muunKey)
                }

                for key in keySet.challengeKeys {
                    try self.keysRepository.store(challengeKey: key, type: key.type)
                }

                let privateKey = try KeyCrypter.decrypt(keySet.encryptedPrivateKey, passphrase: userInput)
                let derivedKey = try privateKey.derive(to: .base)

                try self.keysRepository.store(key: derivedKey)
            })

        runSingle(single)
    }

}
