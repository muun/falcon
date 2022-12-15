//
//  FakeKeysRepository.swift
//  falconTests
//
//  Created by Lucas Serruya on 27/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun
@testable import core

class FakeKeysRepository: KeysRepository {
    var lastStoredChallengeKey: ChallengeKey!
    
    override func storeVerified(challengeKey: ChallengeKey) throws {
        lastStoredChallengeKey = challengeKey
    }
    
    override func storeUnverified(challengeKey: ChallengeKey) throws {
        lastStoredChallengeKey = challengeKey
    }
    
    var markChallengeKeyAsVerifiedForRecoveryCodeCalledCount = 0

    override func markChallengeKeyAsVerifiedForRecoveryCode() {
        markChallengeKeyAsVerifiedForRecoveryCodeCalledCount += 1
    }
    
    var lastStoredMuunPrivateKey: String!
    
    override func store(muunPrivateKey: String) throws {
        lastStoredMuunPrivateKey = muunPrivateKey
    }
    
    var lastStoredMuunKeyFingerprint: String!
    
    override func store(muunKeyFingerprint: String) {
        lastStoredMuunKeyFingerprint = muunKeyFingerprint
    }
    
    var userKey: WalletPrivateKey!
    var muunKey: WalletPrivateKey!

    override func getBasePrivateKey() throws -> WalletPrivateKey {
        return userKey
    }

    override func getCosigningKey() throws -> WalletPublicKey {
        return muunKey.walletPublicKey()
    }
}
