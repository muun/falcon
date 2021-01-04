//
//  RequestChallengeAction.swift
//  falcon
//
//  Created by Manu Herrera on 18/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public class RequestChallengeAction: AsyncAction<Challenge?> {

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "RequestChallengeAction")
    }

    public func run(type: String) {
        runSingle(houstonService.requestChallenge(challengeType: type))
    }

}
