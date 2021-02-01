//
//  FCMTokenAction.swift
//  falcon
//
//  Created by Manu Herrera on 20/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public class FCMTokenAction: AsyncAction<()> {

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "FCMTokenAction")
    }

    public func run(token: String) {
        runSingle(houstonService.updateGcmToken(gcmToken: token))
    }

}
