//
//  StartRecoveryCodeSetupAction.swift
//
//  Created by Lucas Serruya on 20/10/2022.
//

import Foundation
import RxSwift

public class StartRecoverCodeSetupAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let buildChallengeSetupAction: BuildChallengeSetupAction

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         buildChallengeSetupAction: BuildChallengeSetupAction) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.buildChallengeSetupAction = buildChallengeSetupAction

        super.init(name: "StartRecoverCodeSetupAction")
    }

    public func run() -> RecoveryCode {
        let recoveryCode = RecoveryCode.random()

        let (key, setup) = buildChallengeSetupAction.run(type: .RECOVERY_CODE, userInput: recoveryCode.description)

        runSingle(
            houstonService.startChallenge(challengeSetup: setup).map({ response in
                try self.keysRepository.storeUnverified(challengeKey: key)

                if let muunKey = response.muunKey {
                    try self.keysRepository.store(muunPrivateKey: muunKey)
                }
                if let muunKeyFingerprint = response.muunKeyFingerprint {
                    self.keysRepository.store(muunKeyFingerprint: muunKeyFingerprint)
                }
            })
        )

        return recoveryCode
    }
}
