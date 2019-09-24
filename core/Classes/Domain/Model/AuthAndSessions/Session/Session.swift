//
//  Session.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

public struct Session {

    let uuid: String?
    let requestId: String
    let email: String
    let buildType: String
    let version: Int
    let gcmRegistrationToken: String
    let clientType: String = "FALCON"

    public init(uuid: String?, requestId: String, email: String, buildType: String, version: Int, gcmToken: String) {
        self.uuid = uuid
        self.requestId = requestId
        self.email = email
        self.buildType = buildType
        self.version = version
        self.gcmRegistrationToken = gcmToken
    }

}

public struct CreateSessionOk {

    public let isExistingUser: Bool
    public let canUseRecoveryCode: Bool
    public let passwordSetupDate: Date?
    public let recoveryCodeSetupDate: Date?

}
