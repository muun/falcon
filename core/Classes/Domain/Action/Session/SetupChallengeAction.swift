//
//  SetupChallengeAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift
import Libwallet

public class SetupChallengeAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository

    init(houstonService: HoustonService, keysRepository: KeysRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository

        super.init(name: "SetupChallengeAction")
    }

    public func run(type: ChallengeType, userInput: String) {

        let salt = Hashes.randomBytes(count: 8)
        let challengeKey = LibwalletChallengePrivateKey(Data(userInput.stringBytes), salt: Data(salt))!
        let challengePublicKey = challengeKey.pubKeyHex()

        let action = Single.deferred({
                Single.just(try self.buildChallengeSetup(type: type,
                                                         challengePublicKey: challengePublicKey,
                                                         userInput: userInput,
                                                         salt: salt))
            })
            .flatMap(houstonService.setupChallenge(challengeSetup:))
            .do(onSuccess: { response in

                let challengeKey = ChallengeKey(type: type,
                                                publicKey: Data(challengePublicKey.stringBytes),
                                                salt: Data(salt))

                try self.keysRepository.store(challengeKey: challengeKey, type: type)
                try self.keysRepository.store(muunPrivateKey: response.muunKey)
            })
            .asCompletable()

        runCompletable(action)
    }

    private func buildChallengeSetup(type: ChallengeType,
                                     challengePublicKey: String,
                                     userInput: String,
                                     salt: [UInt8]) throws -> ChallengeSetup {

        let encryptedKey = KeyCrypter.encrypt(try keysRepository.getBasePrivateKey(), passphrase: userInput)

        return ChallengeSetup(
            type: type,
            passwordSecretPublicKey: challengePublicKey,
            passwordSecretSalt: salt.toHexString(),
            encryptedPrivateKey: encryptedKey,
            version: Int(Constant.buildVersion)!
        )
    }
}
