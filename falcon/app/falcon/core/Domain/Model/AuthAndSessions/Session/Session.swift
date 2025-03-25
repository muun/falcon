//
//  Session.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public struct CreateLoginSession {

    let client: Client
    let email: String
    // GcmToken is not retrieved until notification permission approval.
    let gcmToken: String?

}

public struct CreateSessionOk {

    public let isExistingUser: Bool
    public let canUseRecoveryCode: Bool
    public let passwordSetupDate: Date?
    public let recoveryCodeSetupDate: Date?

}
