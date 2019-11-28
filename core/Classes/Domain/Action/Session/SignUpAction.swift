//
//  SignUpAction.swift
//  falcon
//
//  Created by Manu Herrera on 18/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift
import Libwallet

public class SignUpAction: AsyncAction<SignupOk> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let preferences: Preferences

    init(houstonService: HoustonService, keysRepository: KeysRepository, preferences: Preferences) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.preferences = preferences

        super.init(name: "SignUpAction")
    }

    public func run(passphrase: String, currencyCode: String) {

        let salt = Hashes.randomBytes(count: 8)

        let challengePrivateKey = LibwalletChallengePrivateKey(Data(passphrase.stringBytes), salt: Data(salt))!
        let challengePublicKey = challengePrivateKey.pubKeyHex()
        let walletPrivateKey = WalletPrivateKey.createRandom()

        let baseKey: WalletPrivateKey
        do {
            baseKey = try walletPrivateKey.derive(to: .base)
        } catch {
            // Abort early if we fail to derive the key
            Logger.log(error: error)
            runSingle(Single.error(error))
            return
        }

        // We send muun the encrypted root and store ourselves the prederived to base path one
        let type: ChallengeType = .PASSWORD
        let setup = ChallengeSetup(
            type: type,
            passwordSecretPublicKey: challengePublicKey,
            passwordSecretSalt: salt.toHexString(),
            encryptedPrivateKey: KeyCrypter.encrypt(walletPrivateKey, passphrase: passphrase),
            version: type.getVersion()
        )

        let single = Single.deferred({
            Single.just(try self.generateSignUpModel(challenge: setup, baseKey: baseKey, currencyCode: currencyCode))
            })
            .flatMap(houstonService.signup(signupObject:))
            .do(onSuccess: { response in
                self.keysRepository.store(cosigningKey: response.cosigningPublicKey)
                try self.keysRepository.store(key: baseKey)

                let challengeKey = ChallengeKey(type: .PASSWORD,
                                                publicKey: Data(challengePublicKey.stringBytes),
                                                salt: Data(salt))
                try self.keysRepository.store(challengeKey: challengeKey, type: .PASSWORD)
            })

        runSingle(single)
    }

    private func generateSignUpModel(challenge: ChallengeSetup, baseKey: WalletPrivateKey, currencyCode: String) throws -> Signup {

        let signUp = Signup(
            firstName: "",
            lastName: "",
            email: preferences.string(forKey: .email),
            primaryCurrency: currencyCode,
            basePublicKey: baseKey.walletPublicKey(),
            passwordChallengeSetup: challenge
        )

        return signUp
    }
}
