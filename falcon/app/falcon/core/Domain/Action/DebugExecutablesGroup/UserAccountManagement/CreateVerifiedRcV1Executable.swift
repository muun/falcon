//
//  CreateVerifiedRcV1Executable.swift
//  Muun
//
//  Created by Lucas Serruya on 17/04/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Libwallet
import RxSwift

// Heads up: This class contains a lot of duplicated production code. This is intentional - we don't
// want to affect production code with customizations for legacy RCs as that might introduce
// new bugs, maintenance costs, and loss of declarativity.
class CreateVerifiedRcV1Executable: DebugExecutable {
    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let userRepository: UserRepository

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         userRepository: UserRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.userRepository = userRepository
    }

    func getTitleForCell() -> String {
        "Create verified RcV1"
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        guard userRepository.getUserEmail() != nil else {
            context.showAlert(
                title: "Setup an email first!",
                message: "Email setup is mandatory for RCV1"
            )
            completion()
            return
        }

        let recoveryCode = createRecoveryCodeV1()
        let salt = SecureRandom.randomBytes(count: 8)
        let privKey = createPrivKey(recoveryCode: recoveryCode, salt: salt)
        let (key, setup) = createKeyAndSetup(
            privKey: privKey,
            recoveryCode: recoveryCode,
            salt: salt
        )

        // swiftlint: disable force_try
        _ = try! startChallenge(
            key: key,
            challengeSetup: setup
        ).toBlocking().first()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.finishRecoverChallenge(
                type: .RECOVERY_CODE,
                recoveryCode: recoveryCode,
                legacyRecoveryCodeSalt: salt
            )

            context.showAlert(
                title: "Your Recovery Code (Copied to your clipboard)",
                message: recoveryCode.description
            )

            UIPasteboard.general.string = recoveryCode.description

            completion()
        })
    }

    // This recovery code type has an unnecessary salt removed in V1.
    private func createRecoveryCodeV1() -> RecoveryCode {
        var recoveryCode = "ABCD-EFHJ-KMNP-QRST-UVWX-YZ23"
        recoveryCode += "-\(createFourRandomNumbersForTheRecoveryCode())"
        recoveryCode += "-\(createFourRandomNumbersForTheRecoveryCode())"

        // swiftlint: disable force_try
        return try! RecoveryCode(code: recoveryCode)
    }

    private func createFourRandomNumbersForTheRecoveryCode() -> Int {
        var lastVal: Int = 0
        repeat {
            lastVal = Int.random(in: 1000...9999)
        } while String(lastVal).contains("0")
        || String(lastVal).contains("1")
        || String(lastVal).contains("6")

        return lastVal
    }

    private func createPrivKey(
        recoveryCode: RecoveryCode,
        salt: Data
    ) -> LibwalletChallengePrivateKey {
        // swiftlint: disable force_try
        return try! doWithError({ error in
            LibwalletRecoveryCodeToKey(
                recoveryCode.description,
                salt.toHexString(),
                error
            )
        })
    }

    private func createKeyAndSetup(
        privKey: LibwalletChallengePrivateKey,
        recoveryCode: RecoveryCode,
        salt: Data
    ) -> (ChallengeKey, ChallengeSetup) {
        var (key, setup) = try! buildChallengeSetup(type: .RECOVERY_CODE,
                                                    userInput: recoveryCode.description,
                                                    privKey: privKey,
                                                    salt: salt
        )

        // Add salt for RcV1.
        key = ChallengeKey(
            type: key.type,
            publicKey: key.publicKey,
            salt: salt,
            challengeVersion: key.challengeVersion
        )

        return (key, setup)

        func buildChallengeSetup(
            type: ChallengeType,
            userInput: String,
            privKey: LibwalletChallengePrivateKey,
            salt: Data
        ) throws -> (challengeKey: ChallengeKey, challengeSetup: ChallengeSetup) {

            let pubKey = privKey.pubKeyHex()

            let encryptedKey = KeyCrypter.encrypt(
                try keysRepository.getBasePrivateKey(),
                passphrase: userInput
            )
            let challengeKey = buildChallengeKey(type: type, pubKey: pubKey, salt: salt)

            // In order to save ourselves from a huge backend refactor, we will continue to send a salt
            // on all challenge setups, but it wont be used for challenge types = RECOVERY_CODE
            let challengeSetup = ChallengeSetup(
                type: type,
                passwordSecretPublicKey: pubKey,
                passwordSecretSalt: salt.toHexString(),
                encryptedPrivateKey: encryptedKey,
                version: type.getVersion()
            )

            return (challengeKey, challengeSetup)
        }

        func buildChallengeKey(
            type: ChallengeType,
            pubKey: String,
            salt: Data
        ) -> ChallengeKey {
            return ChallengeKey(
                type: type,
                publicKey: Data(hex: pubKey),
                salt: nil,
                challengeVersion: 1
            )
        }
    }

    private func startChallenge(
        key: ChallengeKey,
        challengeSetup: ChallengeSetup
    ) -> Completable {
        return houstonService.startChallenge(challengeSetup: challengeSetup).map({ response in
            try self.keysRepository.storeUnverified(challengeKey: key)

            if let muunKey = response.muunKey {
                try self.keysRepository.store(muunPrivateKey: muunKey)
            }
            if let muunKeyFingerprint = response.muunKeyFingerprint {
                self.keysRepository.store(muunKeyFingerprint: muunKeyFingerprint)
            }
        }).asCompletable()
    }

    private func finishRecoverChallenge(
        type: ChallengeType,
        recoveryCode: RecoveryCode,
        legacyRecoveryCodeSalt: Data
    ) {
        _ = try! getChallengePublicKey(
            recoveryCode: recoveryCode,
            legacyRecoveryCodeSalt: legacyRecoveryCodeSalt
        ).flatMapCompletable({ [weak self] in
            guard let self = self else {
                return Completable.error(
                    NSError(domain: "failed_to_retrieve_challenge_key", code: 1)
                )
            }

            return self.houstonService.finishChallenge(
                challengeType: type,
                challengeSetupPublicKey: $0
            ).do(onCompleted: { [weak self] in
                self?.keysRepository.markChallengeKeyAsVerifiedForRecoveryCode()
            })
        }).toBlocking().first()
        
        func getChallengePublicKey(
            recoveryCode: RecoveryCode,
            legacyRecoveryCodeSalt: Data
        ) -> Single<String> {
            // swiftlint:disable force_error_handling
            guard let publicKey = try? convertRecoveryCodeToKey(
                recoveryCode: recoveryCode,
                salt: legacyRecoveryCodeSalt
            ).publicKey.toHexString() else {
                let error = NSError(domain: "failed_to_retrieve_challenge_key", code: 999)
                Logger.log(error: error)
                return Single.error(error)
            }

            return Single.just(publicKey)
        }

        func convertRecoveryCodeToKey(
            recoveryCode: RecoveryCode,
            salt: Data
        ) throws -> ChallengeKey {
            let key = try doWithError({ error in
                LibwalletRecoveryCodeToKey(
                    recoveryCode.segments.joined(separator: RecoveryCode.separator),
                    salt.toHexString(),
                    error
                )
            })

            let type = ChallengeType.RECOVERY_CODE

            return ChallengeKey(
                type: type,
                publicKey: Data(hex: key.pubKeyHex()),
                salt: nil,
                challengeVersion: type.getVersion()
            )
        }
    }
}
