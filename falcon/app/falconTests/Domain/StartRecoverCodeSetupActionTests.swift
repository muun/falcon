//
//  StartRecoverCodeSetupActionTests.swift
//
//  Created by Lucas Serruya on 20/10/2022.
//

import XCTest
@testable import Muun

class StartRecoveryCodeSetupActionTests: MuunTestCase {
    fileprivate var houstonService: FakeHoustonService!
    fileprivate var keysRepository: FakeKeysRepository!
    fileprivate lazy var buildChallengeSetup = BuildChallengeSetupActionFake(keysRepository: keysRepository)
    var expectation: XCTestExpectation?
    lazy var subject = StartRecoverCodeSetupAction(houstonService: houstonService,
                                                   keysRepository: keysRepository,
                                                   buildChallengeSetupAction: buildChallengeSetup)
    
    override func setUp() {
        super.setUp()
        
        houstonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        keysRepository = replace(.singleton, KeysRepository.self, FakeKeysRepository.init)
    }
    
    func test_runUseCase() {
        houstonService.expectedSetupChallengeResponse = SetupChallengeResponse(muunKey: "expected_muun_key",
                                                                               muunKeyFingerprint: "key_fingerprint")
        buildChallengeSetup.expectedKey = ChallengeKey(type: .RECOVERY_CODE,
                                                       publicKey: "expected_challenge_key".data(using: .utf8)!,
                                                       salt: "salt".data(using: .utf8),
                                                       challengeVersion: 1)
        
        expectation = expectation(description: "wait_for_success")
        
        subscribeTo(subject.getValue(), onSuccess: { self.expectation?.fulfill() }) { error in
            XCTFail()
        }
        _ = subject.run()

        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(self.keysRepository.lastStoredChallengeKey, self.buildChallengeSetup.expectedKey)
            XCTAssertEqual(self.keysRepository.lastStoredMuunKeyFingerprint, self.houstonService
                .expectedSetupChallengeResponse.muunKeyFingerprint)
            XCTAssertEqual(self.keysRepository.lastStoredMuunPrivateKey, self.houstonService.expectedSetupChallengeResponse.muunKey)
        }
    }
}
