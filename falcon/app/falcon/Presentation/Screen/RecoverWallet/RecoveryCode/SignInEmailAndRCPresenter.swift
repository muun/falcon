//
//  SignInEmailAndRCPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 30/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift


protocol SignInEmailAndRCPresenterDelegate: BasePresenterDelegate {
    func keySetResponseReceived(keySet: KeySet)
    func setLoading(_ isLoading: Bool)
    func invalidCode()
    func showStaleRcError()
    func showCredentialsDontMatchError(userEmail: String)
}

class SignInEmailAndRCPresenter<Delegate: SignInEmailAndRCPresenterDelegate>: BasePresenter<Delegate> {

    private let requestChallengeAction: RequestChallengeAction
    private let logInAction: LogInAction

    private var recoveryCode: RecoveryCode?
    private let preferences: Preferences

    init(delegate: Delegate,
         requestChallengeAction: RequestChallengeAction,
         logInAction: LogInAction,
         preferences: Preferences) {
        self.requestChallengeAction = requestChallengeAction
        self.logInAction = logInAction
        self.preferences = preferences

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(requestChallengeAction.getState(), onNext: self.onRequestChallengeChange)
        subscribeTo(logInAction.getState(), onNext: self.onLogInChange)
    }

    func requestChallengeAndSignIt(code: RecoveryCode) {
        self.recoveryCode = code
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
                logIn(challenge: challenge)
            }
        }
    }

    private func logIn(challenge: Challenge) {
        logInAction.run(challenge, userInput: recoveryCode?.description ?? "")
    }

    private func onLogInChange(_ result: ActionState<KeySet>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {
                if e.isKindOf(.invalidChallengeSignature) {
                    delegate.invalidCode()
                } else if e.isKindOf(.staleChallengeKey) {
                    delegate.showStaleRcError()
                } else if e.isKindOf(.credentialsDontMatch) {
                    delegate.showCredentialsDontMatchError(userEmail: preferences.string(forKey: .email) ?? "")
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

}
