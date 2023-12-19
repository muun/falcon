//
//  SignUpVerifyEmailPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 18/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift
import core

protocol SignUpVerifyEmailPresenterDelegate: BasePresenterDelegate {
    func onEmailVerified()
    func emailExpired()
}

class SignUpVerifyEmailPresenter<Delegate: SignUpVerifyEmailPresenterDelegate>: BasePresenter<Delegate> {

    internal let fetchNotificationsAction: FetchNotificationsAction
    private let sessionActions: SessionActions
    private let preferences: Preferences
    private let verifyEmailAction: VerifyEmailSetupAction

    init(delegate: Delegate,
         fetchNotificationsAction: FetchNotificationsAction,
         sessionActions: SessionActions,
         preferences: Preferences,
         verifyEmailAction: VerifyEmailSetupAction) {

        self.fetchNotificationsAction = fetchNotificationsAction
        self.sessionActions = sessionActions
        self.preferences = preferences
        self.verifyEmailAction = verifyEmailAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Delay by one second to avoid hammering the backend with requests
        let periodicFetch = buildFetchNotificationsPeriodicAction(intervalInSeconds: 1)

        subscribeTo(periodicFetch, onNext: { _ in })
        subscribeTo(sessionActions.watchEmailAuthorization(), onComplete: self.onEmailAuthorization)
        subscribeTo(sessionActions.watchUser(), onNext: self.onUserChange)
        subscribeTo(verifyEmailAction.getState(), onNext: self.onAuthorizeValue)
    }

    func runVerification(uuid: String) {
        verifyEmailAction.run(uuid: uuid)
    }

    private func onEmailAuthorization() {
        self.delegate.onEmailVerified()
    }

    private func onUserChange(_ user: User?) {
        if let u = user, u.isEmailVerified {
            self.delegate.onEmailVerified()
        }
    }

    private func onAuthorizeValue(value: ActionState<()>) {
        switch value.type {
        case .EMPTY, .LOADING:
            break
        case .VALUE:
            if !sessionActions.isEmailAuthorized() {
                delegate.emailExpired()
            }
        case .ERROR:
            delegate.emailExpired()
        }
    }

    func getUserEmail() -> String {
        return preferences.string(forKey: .email)!
    }

}

extension SignUpVerifyEmailPresenter: NotificationsFetcher {}
