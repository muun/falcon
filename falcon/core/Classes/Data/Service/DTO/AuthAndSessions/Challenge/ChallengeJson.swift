//
//  ChallengeJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct ChallengeJson: Codable {

    let type: ChallengeTypeJson
    let challenge: String
    let salt: String? // Nil for USER_KEY and RECOVERY_CODE (version >= 2) types

}

struct ChallengeSetupJson: Codable {

    let type: ChallengeTypeJson
    let passwordSecretPublicKey: String?
    let passwordSecretSalt: String
    let encryptedPrivateKey: String
    let version: Int

}

enum ChallengeTypeJson: String, Codable {
    /**
     * User-provided password public key will be used to sign Challenge.
     */
    case PASSWORD
    /**
     * User-provided recovery code public key will be used to sign Challenge.
     */
    case RECOVERY_CODE

    /**
     * Fake challenge key type used to sign/verify challenges with the user's private/public key.
     */
    case USER_KEY
}

struct SetupChallengeResponseJson: Codable {
    let muunKey: String?
    let muunKeyFingerprint: String?
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
