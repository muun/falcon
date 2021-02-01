//
//  ChangePasswordEnterRecoveryCodePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift
import core

protocol ChangePasswordEnterRecoveryCodePresenterDelegate: BasePresenterDelegate {
    func setLoading(_ isLoading: Bool)
    func pendingUpdateReceived(challengeType: String, updateUuid: String)
    func invalidRecoveryCode()
}

class ChangePasswordEnterRecoveryCodePresenter<Delegate: ChangePasswordEnterRecoveryCodePresenterDelegate>:
BasePresenter<Delegate> {

    private let beginPasswordChangeAction: BeginPasswordChangeAction
    private let requestChallengeAction: RequestChallengeAction

    init(delegate: Delegate,
         beginPasswordChangeAction: BeginPasswordChangeAction,
         requestChallengeAction: RequestChallengeAction,
         sessionActions: SessionActions) {
        self.beginPasswordChangeAction = beginPasswordChangeAction
        self.requestChallengeAction = requestChallengeAction

        super.init(delegate: delegate)
    }

    private var userInput = ""

    override func setUp() {
        super.setUp()

        subscribeTo(requestChallengeAction.getState(), onNext: self.onRequestChallengeChange)
        subscribeTo(beginPasswordChangeAction.getState(), onNext: self.onBeginPasswordChangeAction)
    }

    func requestChallengeAndSignIt(userInput: String) {
        self.userInput = userInput

        requestChallengeAction.run(type: ChallengeType.RECOVERY_CODE.rawValue)
    }

    private func onRequestChallengeChange(_ result: ActionState<Challenge?>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {
                handleError(e)

            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            if let value = result.value, let challenge = value {
                beginPasswordChange(challenge: challenge)
            }
        }
    }

    private func beginPasswordChange(challenge: Challenge) {
        beginPasswordChangeAction.run(challenge: challenge, userInput: userInput)
    }

    private func onBeginPasswordChangeAction(_ result: ActionState<String>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {

                if e.isKindOf(.invalidChallengeSignature) {
                    delegate.invalidRecoveryCode()
                } else {
                    handleError(e)
                }

            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            if let uuid = result.value {
                delegate.pendingUpdateReceived(challengeType: ChallengeType.RECOVERY_CODE.rawValue, updateUuid: uuid)
            }
        }
    }

}
