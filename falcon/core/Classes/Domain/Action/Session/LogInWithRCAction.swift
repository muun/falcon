//
//  LogInWithRCAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 09/09/2020.
//

import Foundation
import Libwallet
import RxSwift

public class LogInWithRCAction: AsyncAction<(hasEmailSetup: Bool, obfuscatedEmail: String?)> {

    private let houstonService: HoustonService
    private let storeKeySetAction: StoreKeySetAction
    private let preferences: Preferences
    init(houstonService: HoustonService, storeKeySetAction: StoreKeySetAction, preferences: Preferences) {
        self.houstonService = houstonService
        self.storeKeySetAction = storeKeySetAction
        self.preferences = preferences

        super.init(name: "LogInWithRCAction")
    }

    // Try to log in. The response signals if the user needs to verify the email or not
    public func run(challenge: Challenge, recoveryCode: String) {

        do {
            let key = try doWithError({ error in
                LibwalletRecoveryCodeToKey(recoveryCode, nil, error)
            })

            let single = Single.deferred({
                let signature = try key.signSha(Data(hex: challenge.challenge))
                    return Single.just(ChallengeSignature(type: challenge.type, hex: signature.toHexString()))
                })
                .flatMap({ payload in self.houstonService.loginWithRecoveryCode(payload) })
                .do(onSuccess: { rcSessionOk in
                    if let keySet = rcSessionOk.keySet {
                        self.storeKeySetAction.run(keySet: keySet, userInput: recoveryCode)
                        if challenge.type == .RECOVERY_CODE {
                            self.preferences.set(value: true, forKey: .hasResolvedARcChallenge)
                            self.preferences.set(value: true, forKey: .welcomeMessageSeen)
                        }
                    }
                })
                .map({ sessionOk in
                    return (hasEmailSetup: sessionOk.hasEmailSetup, obfuscatedEmail: sessionOk.obfuscatedEmail)
                })

            runSingle(single)

        } catch {
            Logger.fatal(error: error)
        }

    }

}
