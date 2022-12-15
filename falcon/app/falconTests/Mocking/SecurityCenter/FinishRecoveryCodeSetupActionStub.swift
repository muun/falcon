//
//  FinishRecoveryCodeSetupActionStub.swift
//  falconTests
//
//  Created by Lucas Serruya on 01/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import RxSwift
@testable import core

class FinishRecoveryCodeSetupActionStub: FinishRecoverCodeSetupAction {
    lazy var observable = BehaviorSubject(value: ActionState<()>.createEmpty())
    var expectedActionState: ActionState<()>!
    
    override func getState() -> Observable<ActionState<()>> {
        return observable.asObservable()
    }
    
    var runCalledCount = 0
    override func run(type: ChallengeType, recoveryCode: RecoveryCode) {
        runCalledCount += 1
    }
    
    func emitValue() {
        observable.onNext(expectedActionState)
    }
}
