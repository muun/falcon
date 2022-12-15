//
//  FinishRecoveryCodeSetupActionTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 02/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import XCTest
@testable import core
@testable import Muun

import RxSwift

class FinishRecoveryCodeSetupActionTest: MuunTestCase {
    fileprivate var houstonService: FakeHoustonService!
    fileprivate var keysRepository: FakeKeysRepository!
    var expectedRecoveryCode: RecoveryCode!
    var expectation: XCTestExpectation?
    lazy var subject = FinishRecoverCodeSetupAction(houstonService: houstonService, keysRepository: keysRepository)
    
    override func setUp() {
        super.setUp()
        
        houstonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        keysRepository = replace(.singleton, KeysRepository.self, FakeKeysRepository.init)
        expectedRecoveryCode = RecoveryCode.random()
    }
    
    func test_runUseCase() {
        expectation = expectation(description: "wait_for_success")
        
        subscribeTo(subject.getValue(), onSuccess: { self.expectation?.fulfill() }) { error in
            XCTFail()
        }

        subject.run(type: .RECOVERY_CODE, recoveryCode: expectedRecoveryCode)

        waitForExpectations(timeout: 1.0) { _ in
            
            XCTAssertEqual(self.houstonService.finishChallengeCalledCount, 1)
            XCTAssertEqual(self.keysRepository.markChallengeKeyAsVerifiedForRecoveryCodeCalledCount, 1)
        }
    }
    
    func test_runUseCaseButFails() {
        houstonService.expectedError = NSError(domain: "test_error", code: 1)
        
        subscribeTo(subject.getValue(), onSuccess: { }) { error in
            XCTAssertEqual(self.houstonService.finishChallengeCalledCount, 1)
            XCTAssertEqual(self.keysRepository.markChallengeKeyAsVerifiedForRecoveryCodeCalledCount, 0)
            XCTAssertEqual(error as NSError, self.houstonService.expectedError)
        }

        subject.run(type: .RECOVERY_CODE, recoveryCode: expectedRecoveryCode)
    }
}
