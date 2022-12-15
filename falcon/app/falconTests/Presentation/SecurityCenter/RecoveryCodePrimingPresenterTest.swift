//
//  RecoveryCodePrimingPresenterTest.swift
//  falconTests
//
//  Created by Lucas Serruya on 27/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import XCTest
@testable import Muun
@testable import core
import RxSwift

class RecoveryCodePrimingPresenterTest: MuunTestCase {
    let subjectDelegate = RecoveryCodePrimingPresenterDelegateSpy()
    fileprivate var houstonService: FakeHoustonService!
    fileprivate var keysRepository: FakeKeysRepository!
    fileprivate lazy var buildChallengeSetup = BuildChallengeSetupActionFake(keysRepository: keysRepository)
    
    lazy var startRecoveryCodeSetup = StartRecoverySetupActionStub(houstonService: houstonService,
                                                                   keysRepository: keysRepository,
                                                                   buildChallengeSetupAction: buildChallengeSetup)
    
    lazy var subject = RecoveryCodePrimingPresenter(delegate: subjectDelegate, startRecoverySetupAction: startRecoveryCodeSetup)
    
    var expectedRecoveryCode: RecoveryCode!
    
    override func setUp() {
        super.setUp()
        
        houstonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        keysRepository = replace(.singleton, KeysRepository.self, FakeKeysRepository.init)
        expectedRecoveryCode = RecoveryCode.random()
        givenStartRecoveryCodeWillReturn(expectedRecoveryCode)
    }
    
    func test_onUserGoesSuccessfullyToNextScreen() {
        givenPresenterSetupIsCalled()
        givenStartRecoveryCodeEmits(actionState: ActionState.createValue(value: ()))
        
        thenResultFromEmitionHasNotEffect()
        
        whenContinueButtonIsTapped()
        
        thenLoadingHasBeenHideAndRecoveryCodePassedToNextScreenWas(expectedRecoveryCode)
    }
    
    func test_onUserGoesSuccessfullyToNextScreenButTouchContinueButtonBeforeStartRecoveryEmits() {
        givenPresenterSetupIsCalled()
        givenContinueButtonTapped()
        
        thenLoadingIsShownButNothingElseHappens()
        
        whenStartRecoveryCodeEmits(actionState: ActionState.createValue(value: ()))
        
        thenLoadingHasBeenHideAndRecoveryCodePassedToNextScreenWas(expectedRecoveryCode)
    }
    
    func test_onErrorOcurrsOnApiCallAndUserTapsTheContinueButton() {
        givenPresenterSetupIsCalled()
        givenContinueButtonTapped()
        
        thenLoadingIsShownButNothingElseHappens()
        
        whenStartRecoveryCodeEmits(actionState: ActionState.createError(error: NSError(domain: "", code: 1)))
        
        thenLoadingHasBeenHideAndErrorWasShown()
    }
    
    func test_onRetryWasTappedAfterError() {
        givenPresenterSetupIsCalled()
        givenContinueButtonTapped()
        subject.retryTappedAfterError()
        
        givenStartRecoveryCodeEmits(actionState: ActionState.createValue(value: ()))
        
        thenLoadingWasHideAfterRetryAndRecoveryCodePasedToNextScreenWas(expectedRecoveryCode)
    }
}

private extension RecoveryCodePrimingPresenterTest {
    func givenStartRecoveryCodeWillReturn(_ recoveryCode: RecoveryCode) {
        startRecoveryCodeSetup.expectedRecoveryCode = recoveryCode
    }
    
    func givenPresenterSetupIsCalled() {
        subject.setUp()
    }
    
    func givenContinueButtonTapped() {
        subject.onContinueButtonTapped()
    }
    
    func givenStartRecoveryCodeEmits(actionState: ActionState<()>) {
        whenStartRecoveryCodeEmits(actionState: actionState)
    }
    
    func whenContinueButtonIsTapped() {
        givenContinueButtonTapped()
    }
    
    func whenStartRecoveryCodeEmits(actionState: ActionState<()>) {
        startRecoveryCodeSetup.expectedActionState = actionState
        startRecoveryCodeSetup.emitValue()
    }

    func thenLoadingIsShownButNothingElseHappens() {
        XCTAssertNil(subjectDelegate.lastRecoveryCodePassedOnGoToNextScreen)
        XCTAssertEqual(subjectDelegate.goToNextCalledCount, 0)
        XCTAssertTrue(subjectDelegate.continueButtonLoadingLastStates[0])
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates.count, 1)
    }
    
    func thenResultFromEmitionHasNotEffect() {
        XCTAssertNil(subjectDelegate.lastRecoveryCodePassedOnGoToNextScreen)
        XCTAssertEqual(subjectDelegate.goToNextCalledCount, 0)
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates.count, 0)
    }
 
    func thenLoadingHasBeenHideAndRecoveryCodePassedToNextScreenWas(_ expectedRecoveryCode: RecoveryCode) {
        XCTAssertEqual(subjectDelegate.lastRecoveryCodePassedOnGoToNextScreen, expectedRecoveryCode)
        XCTAssertEqual(subjectDelegate.goToNextCalledCount, 1)
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates[1], false)
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates.count, 2)
    }
    
    func thenLoadingHasBeenHideAndErrorWasShown() {
        XCTAssertEqual(subjectDelegate.goToNextCalledCount, 0)
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates[1], false)
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates.count, 2)
        XCTAssertEqual(subjectDelegate.showStartRecoveryCodeSetupErrorCalledCount, 1)
    }
    
    func thenLoadingWasHideAfterRetryAndRecoveryCodePasedToNextScreenWas(_ expectedRecoveryCode: RecoveryCode) {
        XCTAssertEqual(subjectDelegate.continueButtonLoadingCalledCount, 3)
        XCTAssertTrue(subjectDelegate.continueButtonLoadingLastStates[1])
        XCTAssertFalse(subjectDelegate.continueButtonLoadingLastStates[2])
        XCTAssertEqual(subjectDelegate.continueButtonLoadingLastStates.count, 3)
        XCTAssertEqual(subjectDelegate.lastRecoveryCodePassedOnGoToNextScreen, expectedRecoveryCode)
    }
}
