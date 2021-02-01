//
//  FinishEmailSetupPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift
import core

protocol FinishEmailSetupPresenterDelegate: BasePresenterDelegate {
    func passwordSetUp()
    func setLoading(_ isLoading: Bool)
}

class FinishEmailSetupPresenter<Delegate: FinishEmailSetupPresenterDelegate>: BasePresenter<Delegate> {

    private let setUpPasswordAction: SetUpPasswordAction
    private let requestChallengeAction: RequestChallengeAction
    private let sessionActions: SessionActions
    private var password: String = ""

    init(delegate: Delegate,
         setUpPasswordAction: SetUpPasswordAction,
         requestChallengeAction: RequestChallengeAction,
         sessionActions: SessionActions,
         preferences: Preferences) {
        self.setUpPasswordAction = setUpPasswordAction
        self.requestChallengeAction = requestChallengeAction
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(requestChallengeAction.getState(), onNext: self.onRequestChallengeChange)
        subscribeTo(setUpPasswordAction.getState(), onNext: self.onSetUpPasswordChange)
    }

    func requestChallenge(password: String) {
        self.password = password
        requestChallengeAction.run(type: ChallengeType.USER_KEY.rawValue)
    }

    private func onSetUpPasswordChange(_ result: ActionState<()>) {
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
            sessionActions.updateUserEmail()
            delegate.passwordSetUp()
        }
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
                setUpPasswordAction.run(password: password, challenge: challenge)
            }
        }
    }

}
