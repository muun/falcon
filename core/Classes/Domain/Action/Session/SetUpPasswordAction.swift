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
    private let signChallengeWithUserKeyAction: SignChallengeWithUserKeyAction
    private let buildChallengeSetupAction: BuildChallengeSetupAction

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         preferences: Preferences,
         signChallengeWithUserKeyAction: SignChallengeWithUserKeyAction,
         buildChallengeSetupAction: BuildChallengeSetupAction) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.preferences = preferences
        self.signChallengeWithUserKeyAction = signChallengeWithUserKeyAction
        self.buildChallengeSetupAction = buildChallengeSetupAction

        super.init(name: "SetUpPasswordAction")
    }

    public func run(password: String, challenge: Challenge) {

        let (key, setup) = buildChallengeSetupAction.run(type: .PASSWORD, userInput: password)

        // We send muun the encrypted root and store ourselves the prederived to base path one
        let single: Single<()> = Single.deferred({
            Single.just(try self.signChallengeWithUserKeyAction.sign(challenge))
        })
            .flatMap({
                let passwordSetup = PasswordSetup(challengeSignature: $0, challengeSetup: setup)
                return self.houstonService.setUpPassword(passwordSetup)
            })
            .do(onSuccess: { _ in
                try self.keysRepository.store(challengeKey: key)
            }
        )

        runSingle(single)

    }

}
