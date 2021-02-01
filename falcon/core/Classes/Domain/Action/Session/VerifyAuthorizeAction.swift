//
//  VerifyAuthorizeAction.swift
//  falcon
//
//  Created by Manu Herrera on 16/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public class AuthorizeEmailAction: AsyncAction<()> {

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "AuthorizeEmailAction")
    }

    public func run(uuid: String) {
        runSingle(houstonService.authorizeSession(linkAction: LinkAction(uuid: uuid)))
    }

    public func runChangePasswordVerification(uuid: String) {
        runSingle(houstonService.verifyChangePassword(linkAction: LinkAction(uuid: uuid)))
    }

}
