//
//  ChallengeJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public struct Challenge {

    let type: ChallengeType
    let challenge: String
    let salt: String? // Nil for USER_KEY type

}

struct ChallengeSetup {

    let type: ChallengeType
    let passwordSecretPublicKey: String?
    let passwordSecretSalt: String
    let encryptedPrivateKey: String
    let version: Int

}

public enum ChallengeType: String {
    case PASSWORD
    case RECOVERY_CODE
    case USER_KEY

    func getVersion() -> Int {
        switch self {
        case .PASSWORD, .USER_KEY: return 1

        // Version 2 was added during the email-less recovery feature, build version >= 51
        // Version 1 is deprecated and only used in older clients
        case .RECOVERY_CODE: return 2
        }
    }
}

struct SetupChallengeResponse {
    let muunKey: String?
}

struct PendingChallengeUpdate {
    let uuid: String
    let type: ChallengeType
}

struct ChallengeSignature {
    let type: ChallengeType
    let hex: String
}

struct ChallengeUpdate {
    let uuid: String
    let challengeSetup: ChallengeSetup
}
