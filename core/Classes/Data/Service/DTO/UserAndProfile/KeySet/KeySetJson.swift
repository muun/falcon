//
//  KeySet.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct KeySetJson: Codable {

    let encryptedPrivateKey: String
    let muunKey: String?
    let challengeKeys: [ChallengeKeyJson]

}

struct ChallengeKeyJson: Codable {

    let type: ChallengeTypeJson
    let publicKey: String
    let salt: String

}
