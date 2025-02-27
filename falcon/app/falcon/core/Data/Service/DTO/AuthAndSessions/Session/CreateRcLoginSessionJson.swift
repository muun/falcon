//
//  CreateRcLoginSessionJson.swift
//  Created by Manu Herrera on 27/08/2020.
//

import Foundation

struct CreateRcLoginSessionJson: Codable {

    let client: ClientJson
    // GcmToken is not retrieved until notification permission approval.
    let gcmToken: String?
    let challengeKeyJson: ChallengeKeyJson

}

struct CreateSessionRcOkJson: Codable {

    let keySet: KeySetJson?
    let hasEmailSetup: Bool
    let obfuscatedEmail: String?

}
