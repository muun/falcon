//
//  SetupChallengeAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

public class SetupChallengeAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let buildChallengeSetupAction: BuildChallengeSetupAction

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         buildChallengeSetupAction: BuildChallengeSetupAction) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.buildChallengeSetupAction = buildChallengeSetupAction

        super.init(name: "SetupChallengeAction")
    }

    public func run(type: ChallengeType, userInput: String) {

        let (key, setup) = buildChallengeSetupAction.run(type: type, userInput: userInput)

        runSingle(
            houstonService.setupChallenge(challengeSetup: setup).map({ response in
                try self.keysRepository.storeVerified(challengeKey: key)

                if let muunKey = response.muunKey {
                    try self.keysRepository.store(muunPrivateKey: muunKey)
                }
                if let muunKeyFingerprint = response.muunKeyFingerprint {
                    self.keysRepository.store(muunKeyFingerprint: muunKeyFingerprint)
                }
            })
        )
    }
}
