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
    let challengeKeys: [ChallengeKey]

}

public struct ChallengeKey {

    let type: ChallengeType
    let publicKey: Data
    let salt: Data

}
