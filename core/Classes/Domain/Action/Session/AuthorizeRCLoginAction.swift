//
//  AuthorizeRCLoginAction.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 21/09/2020.
//

import Foundation

public class AuthorizeRCLoginAction: AsyncAction<()> {

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "AuthorizeRCLoginAction")
    }

    public func run(uuid: String) {
        runSingle(houstonService.authorizeLoginWithRecoveryCode(linkAction: LinkAction(uuid: uuid)))
    }

}
