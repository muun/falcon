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
    private let preferences: Preferences
    private let clientSelector: ClientSelector

    init(houstonService: HoustonService,
         storeKeySetAction: StoreKeySetAction,
         preferences: Preferences,
         clientSelector: ClientSelector) {
        self.houstonService = houstonService
        self.storeKeySetAction = storeKeySetAction
        self.preferences = preferences
        self.clientSelector = clientSelector

        super.init(name: "LogInAction")
    }

    public func run(_ challenge: Challenge, userInput: String) {
        do {
            let key = try getChallengePrivateKey(challenge: challenge, userInput: userInput)

            let single = Single.deferred({
                let signature = try key.signSha(Data(hex: challenge.challenge))
                return Single.just(self.getLoginJson(challenge: challenge,
                                                     pubKeyHex: key.pubKeyHex(),
                                                     signatureHex: signature.toHexString()))
                })
                .flatMap({ payload in self.houstonService.logIn(loginJson: payload) })
                .do(onSuccess: { keySet in
                    self.storeKeySetAction.run(keySet: keySet, userInput: userInput)
                    if challenge.type == .RECOVERY_CODE {
                        self.preferences.set(value: true, forKey: .hasResolvedARcChallenge)
                        self.preferences.set(value: true, forKey: .welcomeMessageSeen)
                    }
                })

            runSingle(single)
        } catch {
            Logger.fatal(error: error)
        }
    }

    private func getLoginJson(challenge: Challenge, pubKeyHex: String, signatureHex: String) -> LoginJson {
        let challengeKeyVersion = challenge.type == .RECOVERY_CODE ? 2 : 1
        let challengeTypeJson = challenge.type.toJson()
        let challengePublicKey = ChallengeKeyJson(type: challengeTypeJson,
                                                  publicKey: pubKeyHex,
                                                  salt: challenge.salt,
                                                  challengeVersion: challengeKeyVersion)
        let loginJson = LoginJson(type: challengeTypeJson,
                                  hex: signatureHex,
                                  challengePublicKey: challengePublicKey,
                                  deviceCheckToken: clientSelector.run().deviceCheckToken)

        return loginJson
    }

    private func getChallengePrivateKey(challenge: Challenge, userInput: String) throws
    -> LibwalletChallengePrivateKey {
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
