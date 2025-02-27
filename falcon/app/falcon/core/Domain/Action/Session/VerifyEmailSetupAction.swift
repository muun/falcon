//
//  VerifyEmailSetupAction.swift
//  Created by Manu Herrera on 18/09/2020.
//

import Foundation

public class VerifyEmailSetupAction: AsyncAction<()> {

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "VerifyEmailSetupAction")
    }

    public func run(uuid: String) {
        runSingle(houstonService.verifySignUp(linkAction: LinkAction(uuid: uuid)))
    }

}
