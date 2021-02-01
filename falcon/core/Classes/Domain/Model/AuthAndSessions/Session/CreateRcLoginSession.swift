//
//  CreateRcLoginSession.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 27/08/2020.
//

import Foundation

struct CreateRcLoginSession {

    let client: Client
    let gcmToken: String
    let challengeKey: ChallengeKey

}

struct CreateSessionRcOk {

    let keySet: KeySet?
    let hasEmailSetup: Bool
    let obfuscatedEmail: String?

}
