//
//  BeginPasswordChangeAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 28/07/2020.
//

import Foundation
import Libwallet
import RxSwift

public class BeginPasswordChangeAction: AsyncAction<String> {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(houstonService: HoustonService, keysRepository: KeysRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository

        super.init(name: "BeginPasswordChangeAction")
    }

    public func run(challenge: Challenge, userInput: String) {

        let challengePrivateKey = getChallengePrivateKey(challenge: challenge, userInput: userInput)
        let single = Single.deferred({
            let signature = try challengePrivateKey.signSha(Data(hex: challenge.challenge))
                return Single.just(ChallengeSignature(type: challenge.type, hex: signature.toHexString()))
            })
            .flatMap({ payload in
                self.houstonService.beginPasswordChange(challengeSignature: payload)
            })
            .flatMap({ pendingChallengeUpdate in
                return Single.just(pendingChallengeUpdate.uuid)
            })

        runSingle(single)
    }

    private func getChallengePrivateKey(challenge: Challenge, userInput: String) -> LibwalletChallengePrivateKey {
        do {
            let challengePrivateKey: LibwalletChallengePrivateKey
            if challenge.type == .PASSWORD {
                challengePrivateKey = LibwalletChallengePrivateKey(
                    Data(userInput.stringBytes),
                    salt: Data(hex: challenge.salt!) // Should not be null at this point
                )!
            } else if challenge.type == .RECOVERY_CODE {
                challengePrivateKey = try doWithError({ error in
                    LibwalletRecoveryCodeToKey(userInput, challenge.salt, error)
                })
            } else {
                Logger.fatal("Can't change password with challenge type: \(challenge.type)")
            }

            return challengePrivateKey
        } catch {
            Logger.fatal(error: error)
        }
    }

}
