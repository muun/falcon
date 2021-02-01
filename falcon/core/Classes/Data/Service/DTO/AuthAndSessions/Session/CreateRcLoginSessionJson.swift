//
//  CreateRcLoginSessionJson.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 27/08/2020.
//

import Foundation

struct CreateRcLoginSessionJson: Codable {

    let client: ClientJson
    let gcmToken: String
    let challengeKeyJson: ChallengeKeyJson

}

struct CreateSessionRcOkJson: Codable {

    let keySet: KeySetJson?
    let hasEmailSetup: Bool
    let obfuscatedEmail: String?

}
