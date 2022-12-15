//
//  FinishPasswordChangeAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 31/07/2020.
//

import Foundation
import Libwallet
import RxSwift

public class FinishPasswordChangeAction: AsyncAction<()> {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService
    private let buildChallengeSetupAction: BuildChallengeSetupAction

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         buildChallengeSetupAction: BuildChallengeSetupAction) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.buildChallengeSetupAction = buildChallengeSetupAction

        super.init(name: "FinishPasswordChangeAction")
    }

    public func run(password: String, uuid: String) {

        let (key, setup) = buildChallengeSetupAction.run(type: .PASSWORD, userInput: password)

        let update = ChallengeUpdate(uuid: uuid, challengeSetup: setup)
        runSingle(
            houstonService.finishPasswordChange(challengeUpdate: update).map({ _ in
                try self.keysRepository.storeVerified(challengeKey: key)
            })
        )

    }

}
