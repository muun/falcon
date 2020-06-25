//
//  ChallengeJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

public struct Challenge {

    let type: ChallengeType
    let challenge: String
    let salt: String

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
    case ANON

    func getVersion() -> Int {
        switch self {
        case .PASSWORD, .RECOVERY_CODE, .ANON: return 1
        }
    }
}

struct SetupChallengeResponse {
    let muunKey: String
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
