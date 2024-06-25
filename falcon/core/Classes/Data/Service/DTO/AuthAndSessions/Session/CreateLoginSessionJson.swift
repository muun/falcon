//
//  Session.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

enum SessionStatus: String, Codable {
    /**
     * The session requires signing the recovery code challenge.
     */
    case BLOCKED_BY_RC

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

struct CreateLoginSessionJson: Codable {

    let client: ClientJson
    let email: String
    // GcmToken is not retrieved until notification permission approval.
    let gcmToken: String?

}

struct CreateSessionOkJson: Codable {

    let isExistingUser: Bool
    let canUseRecoveryCode: Bool
    let passwordSetupDate: Date?
    let recoveryCodeSetupDate: Date?

}
