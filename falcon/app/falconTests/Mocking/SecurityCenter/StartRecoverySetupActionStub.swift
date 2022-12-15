//
//  StartRecoverySetupActionStub.swift
//  falconTests
//
//  Created by Lucas Serruya on 27/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import core
import RxSwift

class StartRecoverySetupActionStub: StartRecoverCodeSetupAction {
    lazy var observable = BehaviorSubject(value: ActionState<()>.createEmpty())
    var expectedActionState: ActionState<()>!
    
    override func getState() -> Observable<ActionState<()>> {
        return observable.asObservable()
    }
    
    var expectedRecoveryCode: RecoveryCode!
    var runCalledCount = 0
    override func run() -> RecoveryCode {
        runCalledCount += 1
        return expectedRecoveryCode
    }
    
    func emitValue() {
        observable.onNext(expectedActionState)
    }
}
