//
//  KeySet.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public struct KeySet {

    let encryptedPrivateKey: String
    let muunKey: String?
    let muunKeyFingerprint: String?
    let challengeKeys: [ChallengeKey]

}

public struct ChallengeKey {

    let type: ChallengeType
    let publicKey: Data
    let salt: Data? // Nil for USER_KEY and RC version >= 2 type

    // This is optional because it was introduced after the object was already saved on the secure storage
    // and otherwise it will crash when trying to decode it
    let challengeVersion: Int?

    // Use this method to access the version
    func getChallengeVersion() -> Int {
        return challengeVersion ?? 0
    }

}
