//
//  SignInPasswordPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 30/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift


protocol SignInPasswordPresenterDelegate: BasePresenterDelegate {
    func setLoading(_ isLoading: Bool)
    func keySetResponseReceived(keySet: KeySet)
    func invalidPassword()
}

class SignInPasswordPresenter<Delegate: SignInPasswordPresenterDelegate>: BasePresenter<Delegate> {

    private let logInAction: LogInAction
    private let compatLogInAction: CompatLogInAction
    private let requestChallengeAction: RequestChallengeAction

    init(delegate: Delegate,
         logInAction: LogInAction,
         compatLogInAction: CompatLogInAction,
         requestChallengeAction: RequestChallengeAction) {
        self.logInAction = logInAction
        self.compatLogInAction = compatLogInAction
        self.requestChallengeAction = requestChallengeAction

        super.init(delegate: delegate)
    }

    private var userInput = ""

    override func setUp() {
        super.setUp()

        subscribeTo(requestChallengeAction.getState(), onNext: self.onRequestChallengeChange)
        subscribeTo(logInAction.getState(), onNext: self.onLogInChange)
    }

    func requestChallengeAndSignIt(userInput: String) {
        self.userInput = userInput

        requestChallengeAction.run(type: ChallengeType.PASSWORD.rawValue)
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
            if let result = result.value {
                if let challenge = result {
                    logIn(challenge: challenge)
                } else {
                    loginCompatWithoutChallenge()
                }
            }
        }
    }

    private func logIn(challenge: Challenge) {
        logInAction.run(challenge, userInput: userInput)
    }

    private func loginCompatWithoutChallenge() {
        compatLogInAction.run(userInput: userInput)
    }

    private func onLogInChange(_ result: ActionState<KeySet>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {

                if e.isKindOf(.invalidChallengeSignature) {
                    delegate.invalidPassword()
                } else {
                    handleError(e)
                }

            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            if let value = result.value {
                delegate.keySetResponseReceived(keySet: value)
            }
        }
    }

    func isValidPassword(_ text: String) -> Bool {
        return text.count >= 8
    }

}
