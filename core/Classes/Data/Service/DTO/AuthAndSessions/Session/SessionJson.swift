//
//  Session.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

enum SessionStatus: String, Codable {
    /**
     * The session has been created with an e-mail, and has a Beam channel.
     */
    case CREATED

    /**
     * The session requires clicking an email link sent by Houston before proceeding.
     */
    case BLOCKED_BY_EMAIL

    /**
     * The session has been cleared by Houston after the email link was clicked.
     */
    case AUTHORIZED_BY_EMAIL

    /**
     * The session has a User attached and is ready to use all available endpoints.
     */
    case LOGGED_IN

    /**
     * The session has been expired.
     */
    case EXPIRED
}

struct SessionJson: Codable {

    let uuid: String?
    let requestId: String
    let email: String
    let buildType: String
    let version: Int
    let gcmRegistrationToken: String
    let clientType: String

}

struct CreateSessionOkJson: Codable {

    let isExistingUser: Bool
    let canUseRecoveryCode: Bool
    let passwordSetupDate: Date?
    let recoveryCodeSetupDate: Date?

}
