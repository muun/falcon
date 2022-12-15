//
//  FinishRecoveryCodeSetupPresenterTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 01/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import XCTest
@testable import Muun
@testable import core

class FinishRecoveryCodeSetupPresenterTest: MuunTestCase {
    let subjectDelegate = FinishRecoveryCodeSetupPresenterDelegateSpy()
    fileprivate var houstonService: FakeHoustonService!
    fileprivate var keysRepository: FakeKeysRepository!
    lazy var finishAction = FinishRecoveryCodeSetupActionStub(houstonService: houstonService,
                                                              keysRepository: keysRepository)

    lazy var subject = FinishRecoveryCodeSetupPresenter(delegate: subjectDelegate,
                                                        state: RecoveryCode.random(),
                                                        finishRecoveryCodeSetupAction: finishAction)
    
    override func setUp() {
        super.setUp()
        
        houstonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        keysRepository = replace(.singleton, KeysRepository.self, FakeKeysRepository.init)
    }
    
    func test_confirmSuccessfully() {
        finishAction.expectedActionState = ActionState.createValue(value: ())
        subject.confirm()
        
        finishAction.emitValue()
        
        XCTAssertEqual(finishAction.runCalledCount, 1)
        XCTAssertEqual(subjectDelegate.challengeSuccessCalledCount, 1)
    }
    
    func test_confirmFails() {
        finishAction.expectedActionState = ActionState.createError(error: NSError(domain: "", code: 1))
        subject.confirm()
        
        finishAction.emitValue()
        
        XCTAssertEqual(finishAction.runCalledCount, 1)
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates[0], false) //Loading should be shown first BUT currently that responsability is on the view controller
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates.count, 1)
        XCTAssertEqual(subjectDelegate.showFinishErrorSetupErrorCalledCount, 1)
    }
    
    func test_retryAndFails() {
        finishAction.expectedActionState = ActionState.createError(error: NSError(domain: "", code: 1))
        subject.confirm()
        finishAction.emitValue()
        subject.retryTappedAfterError()
        
        finishAction.emitValue()
        
        XCTAssertEqual(finishAction.runCalledCount, 2) // the first run is needed in order to subscribe the presenter to the action
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates[0], false) //Loading should be shown first BUT currently that responsability is on the view controller
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates[1], true)
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates[2], false) //hides loading after
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates.count, 3)
        XCTAssertEqual(subjectDelegate.showFinishErrorSetupErrorCalledCount, 2)
    }
    
    func test_retryAndSuccess() {
        finishAction.expectedActionState = ActionState.createError(error: NSError(domain: "", code: 1))
        subject.confirm()
        finishAction.emitValue()
        finishAction.expectedActionState = ActionState.createValue(value: ())
        subject.retryTappedAfterError()

        finishAction.emitValue()

        XCTAssertEqual(finishAction.runCalledCount, 2) // the first run is needed in order to subscribe the presenter to the action
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates[0], false) //Loading should be shown first BUT currently that responsability is on the view controller
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates[1], true) //Loading should be shown first BUT currently that responsability is on the view controller
        XCTAssertEqual(subjectDelegate.finishButtonLoadingStates.count, 2)
        XCTAssertEqual(subjectDelegate.challengeSuccessCalledCount, 1)
    }
}
