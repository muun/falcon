//
//  NewOperationStateMachine.swift
//  falcon
//
//  Created by Federico Bond on 06/07/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import RxSwift
import Libwallet
import core

class NewOperationStateMachine {
    private let subject: BehaviorSubject<NewopStateProtocol> = BehaviorSubject(value: NewopStartState())
    private let listener: Listener

    init() {
        listener = Listener(subject: subject)
        subject.onNext(NewopNewOperationFlow(listener)!)
    }

    func asObservable() -> Observable<NewopStateProtocol> {
        return subject.asObservable()
    }

    func value() throws -> NewopStateProtocol {
        return try subject.value()
    }

    func withState<T: NewopStateProtocol>(_ f: (_ state: T) throws -> Void) throws {
        if let v = try value() as? T {
            try f(v)
        }
    }

}

class Listener: NSObject, NewopTransitionListenerProtocol {
    private let subject: BehaviorSubject<NewopStateProtocol>

    init(subject: BehaviorSubject<NewopStateProtocol>) {
        self.subject = subject
    }

    func onResolve(_ nextState: NewopResolveState?) {
        subject.onNext(nextState!)
    }

    func onEnterAmount(_ nextState: NewopEnterAmountState?) {
        subject.onNext(nextState!)
    }

    func onEnterDescription(_ nextState: NewopEnterDescriptionState?) {
        subject.onNext(nextState!)
    }

    func onConfirm(_ nextState: NewopConfirmState?) {
        subject.onNext(nextState!)
    }

    func onConfirmLightning(_ nextState: NewopConfirmLightningState?) {
        subject.onNext(nextState!)
    }

    func onEditFee(_ nextState: NewopEditFeeState?) {
        subject.onNext(nextState!)
    }

    func onError(_ nextState: NewopErrorState?) {
        subject.onNext(nextState!)
    }

    func onBalanceError(_ nextState: NewopBalanceErrorState?) {
        subject.onNext(nextState!)
    }

    func onStart(_ nextState: NewopStartState?) {
        subject.onNext(nextState!)
    }

    func onValidate(_ nextState: NewopValidateState?) {
        subject.onNext(nextState!)
    }

    func onValidateLightning(_ nextState: NewopValidateLightningState?) {
        subject.onNext(nextState!)
    }

    func onAbort(_ nextState: NewopAbortState?) {
        subject.onNext(nextState!)
    }
}
