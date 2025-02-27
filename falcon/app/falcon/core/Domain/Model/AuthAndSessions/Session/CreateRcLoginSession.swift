//
//  CreateRcLoginSession.swift
//  Created by Manu Herrera on 27/08/2020.
//

import Foundation

struct CreateRcLoginSession {

    let client: Client
    // GcmToken is not retrieved until notification permission approval.
    let gcmToken: String?
    let challengeKey: ChallengeKey

}

struct CreateSessionRcOk {

    let keySet: KeySet?
    let hasEmailSetup: Bool
    let obfuscatedEmail: String?

}
