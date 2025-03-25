//
//  StartEmailSetupAction.swift
//
//  Created by Manu Herrera on 28/04/2020.
//

import Foundation
import RxSwift
import Libwallet

public class StartEmailSetupAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let preferences: Preferences
    private let signChallengeAction: SignChallengeWithUserKeyAction

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         preferences: Preferences,
         signChallengeAction: SignChallengeWithUserKeyAction) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.preferences = preferences
        self.signChallengeAction = signChallengeAction

        super.init(name: "StartEmailSetupAction")
    }

    public func run(email: String, challenge: Challenge) {

        do {
            let challengeSignature = try signChallengeAction.sign(challenge)
            let emailSetup = StartEmailSetup(email: email, challengeSignature: challengeSignature)
            let single = houstonService.startEmailSetup(emailSetup)

            runSingle(single)

        } catch {
            fatalError("Could not extract anon secret or sign the challenge")
        }

    }
}
