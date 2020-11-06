//
//  BuildChallengeSetupAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 25/08/2020.
//

import Foundation
import RxSwift
import Libwallet

public class BuildChallengeSetupAction: AsyncAction<()> {

    private let keysRepository: KeysRepository

    init(keysRepository: KeysRepository) {
        self.keysRepository = keysRepository

        super.init(name: "BuildChallengeSetupAction")
    }

    // Returns a Challenge Key to be stored in the phone and a Challenge Setup prepared to be sent to the backend
    func run(type: ChallengeType, userInput: String) -> (challengeKey: ChallengeKey, challengeSetup: ChallengeSetup) {

        let salt = Hashes.randomBytes(count: 8)

        do {
            let privKey = try getPrivateChallengeKey(type: type, userInput: userInput, salt: salt)
            let pubKey = privKey.pubKeyHex()

            let encryptedKey = KeyCrypter.encrypt(try keysRepository.getBasePrivateKey(), passphrase: userInput)
            let challengeKey = buildChallengeKey(type: type, pubKey: pubKey, salt: salt)

            // In order to save ourselves from a huge backend refactor, we will continue to send a salt on all challenge
            // setups, but it wont be used for challenge types = RECOVERY_CODE
            let challengeSetup = ChallengeSetup(
                type: type,
                passwordSecretPublicKey: pubKey,
                passwordSecretSalt: salt.toHexString(),
                encryptedPrivateKey: encryptedKey,
                version: type.getVersion()
            )

            return (challengeKey, challengeSetup)
        } catch {
            Logger.fatal(error: error)
        }
    }

    private func getPrivateChallengeKey(type: ChallengeType, userInput: String, salt: [UInt8]) throws
        -> LibwalletChallengePrivateKey {
        switch type {
        case .PASSWORD:
            return LibwalletChallengePrivateKey(Data(userInput.stringBytes), salt: Data(salt))!
        case .RECOVERY_CODE:
            return try doWithError({ error in
                LibwalletRecoveryCodeToKey(userInput, nil, error)
            })
        default:
            Logger.fatal("No priv challenge key for type: \(type)")
        }
    }

    private func buildChallengeKey(type: ChallengeType, pubKey: String, salt: [UInt8]) -> ChallengeKey {
        switch type {
        case .PASSWORD:
            return ChallengeKey(
                type: type,
                publicKey: Data(hex: pubKey),
                salt: Data(salt),
                challengeVersion: type.getVersion()
            )
        case .RECOVERY_CODE:
            return ChallengeKey(
                type: type,
                publicKey: Data(hex: pubKey),
                salt: nil,
                challengeVersion: type.getVersion()
            )
        default:
            Logger.fatal("No challenge key for type: \(type)")
        }
    }
}
