//
//  SetUpPasswordAction.swift
//  core
//
//  Created by Manu Herrera on 29/04/2020.
//

import Foundation
import RxSwift
import Libwallet

public class SetUpPasswordAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let preferences: Preferences
    private let signAnonChallengeAction: SignAnonChallengeAction

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         preferences: Preferences,
         signAnonChallengeAction: SignAnonChallengeAction) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.preferences = preferences
        self.signAnonChallengeAction = signAnonChallengeAction

        super.init(name: "SetUpPasswordAction")
    }

    public func run(password: String, challenge: Challenge) {

        do {
            let salt = Hashes.randomBytes(count: 8)
            let challengePrivateKey = LibwalletChallengePrivateKey(Data(password.stringBytes), salt: Data(salt))!
            let challengePublicKeyHex = challengePrivateKey.pubKeyHex()
            let walletPrivateKey = try keysRepository.getBasePrivateKey()

            // We send muun the encrypted root and store ourselves the prederived to base path one
            let type: ChallengeType = .PASSWORD
            let setup = ChallengeSetup(
                type: type,
                passwordSecretPublicKey: challengePublicKeyHex,
                passwordSecretSalt: salt.toHexString(),
                encryptedPrivateKey: KeyCrypter.encrypt(walletPrivateKey, passphrase: password),
                version: type.getVersion()
            )

            let challengeKeyModel = ChallengeKey(type: .PASSWORD,
                                                 publicKey: Data(hex: challengePublicKeyHex),
                                                 salt: Data(salt))

            let single: Single<()> = Single.deferred({
                Single.just(try self.signAnonChallengeAction.sign(challenge))
            })
                .flatMap({
                    let passwordSetup = PasswordSetup(challengeSignature: $0, challengeSetup: setup)
                    return self.houstonService.setUpPassword(passwordSetup)
                })
                .do(onSuccess: { _ in
                    try self.keysRepository.store(challengeKey: challengeKeyModel, type: .PASSWORD)
                }
            )

            runSingle(single)

        } catch {
            fatalError("Could not extract anon secret or sign the challenge")
        }
    }

}
