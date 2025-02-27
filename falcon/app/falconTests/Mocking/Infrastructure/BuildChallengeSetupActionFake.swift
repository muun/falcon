//
//  BuildChallengeSetupActionFake.swift
//  falconTests
//
//  Created by Lucas Serruya on 27/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun


class BuildChallengeSetupActionFake: BuildChallengeSetupAction {
    var expectedKey: ChallengeKey!
    let returnedChallenge = ChallengeSetup(type: .RECOVERY_CODE,
                                           passwordSecretPublicKey: "psw",
                                           passwordSecretSalt: "psw_salt",
                                           encryptedPrivateKey: "",
                                           version: 1)

    override func run(type: ChallengeType, userInput: String) -> (challengeKey: ChallengeKey, challengeSetup: ChallengeSetup) {
        return (expectedKey, returnedChallenge)
    }
}
