//
//  KeySet.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet

public struct KeySet {

    let encryptedPrivateKey: String
    let muunKey: String?
    let muunKeyFingerprint: String?
    let challengeKeys: [ChallengeKey]

}

public struct ChallengeKey: Equatable {

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

    func encryptKey(_ privateKey: WalletPrivateKey, muunPrivateKey: String) throws -> String {

        let challengePublicKey = try doWithError({ error in
            LibwalletNewChallengePublicKeyFromSerialized(publicKey, error)
        })

        return try doWithError({ error in
            challengePublicKey.encryptKey(
                privateKey.key,
                recoveryCodeSalt: salt,
                birthday: 0xFFFF, // The birthday for the user key isn't used
                muunPrivateKey: muunPrivateKey,
                error: error
            )
        })
    }
    
    func getChecksum() throws -> String {
        let challengePublicKey = try doWithError({ error in
            LibwalletNewChallengePublicKeyFromSerialized(publicKey, error)
        })
        
        return challengePublicKey.getChecksum()
    }

}
