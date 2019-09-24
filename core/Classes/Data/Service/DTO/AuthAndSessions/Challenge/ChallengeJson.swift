//
//  ChallengeJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

struct ChallengeJson: Codable {

    let type: ChallengeTypeJson
    let challenge: String
    let salt: String

}

struct ChallengeSetupJson: Codable {

    let type: ChallengeTypeJson
    let passwordSecretPublicKey: String?
    let passwordSecretSalt: String
    let encryptedPrivateKey: String
    let version: Int

}

enum ChallengeTypeJson: String, Codable {
    case PASSWORD
    case RECOVERY_CODE
}

struct SetupChallengeResponseJson: Codable {
    let muunKey: String
}

struct PendingChallengeUpdateJson: Codable {
    let uuid: String
    let type: ChallengeTypeJson
}

struct ChallengeSignatureJson: Codable {
    let type: ChallengeTypeJson
    let hex: String
}

struct ChallengeUpdateJson: Codable {
    let uuid: String
    let challengeSetup: ChallengeSetupJson
}
