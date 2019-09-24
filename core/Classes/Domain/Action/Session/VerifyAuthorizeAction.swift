//
//  VerifyAuthorizeAction.swift
//  falcon
//
//  Created by Manu Herrera on 16/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public class VerifyAuthorizeAction: AsyncAction<()> {

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "VerifyAuthorizeAction")
    }

    public func run(uuid: String) {
        let linkAction = LinkAction(uuid: uuid)

        runSingle(houstonService.authorizeSession(linkAction: linkAction))
    }

}
