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

    private let houstonService: HoustonService
    private let storeKeySetAction: StoreKeySetAction

    init(houstonService: HoustonService, storeKeySetAction: StoreKeySetAction) {
        self.houstonService = houstonService
        self.storeKeySetAction = storeKeySetAction

        super.init(name: "LogInAction")
    }

    public func run(_ challenge: Challenge, userInput: String) {

        do {
            let key = try getChallengePrivateKey(challenge: challenge, userInput: userInput)

            let single = Single.deferred({
                let signature = try key.signSha(Data(hex: challenge.challenge))
                    return Single.just(ChallengeSignature(type: challenge.type, hex: signature.toHexString()))
                })
                .flatMap({ payload in self.houstonService.logIn(challengeSignature: payload) })
                .do(onSuccess: { keySet in
                    self.storeKeySetAction.run(keySet: keySet, userInput: userInput)
                })

            runSingle(single)
        } catch {
            Logger.fatal(error: error)
        }
    }

    private func getChallengePrivateKey(challenge: Challenge, userInput: String) throws -> LibwalletChallengePrivateKey {
        switch challenge.type {
        case .PASSWORD:
            return LibwalletChallengePrivateKey(
                Data(userInput.stringBytes),
                salt: Data(hex: challenge.salt!) // Should not be null on this flow
            )!

        case .RECOVERY_CODE:
            return try doWithError({ error in
                // salt will be null for versions >= 2
                LibwalletRecoveryCodeToKey(userInput, challenge.salt, error)
            })

        default:
            Logger.fatal("Asking for private key for wrong challenge type: \(challenge.type)")
        }
    }

}
