//
//  SignInAuthorizeEmailPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 29/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift


protocol SignInAuthorizeEmailPresenterDelegate: BasePresenterDelegate {
    func onEmailVerified()
    func emailExpired()
}

class SignInAuthorizeEmailPresenter<Delegate: SignInAuthorizeEmailPresenterDelegate>: BasePresenter<Delegate> {

    internal let fetchNotificationsAction: FetchNotificationsAction
    private let sessionActions: SessionActions
    private let preferences: Preferences
    private let authorizeEmailAction: AuthorizeEmailAction

    init(delegate: Delegate,
         fetchNotificationsAction: FetchNotificationsAction,
         sessionActions: SessionActions,
         preferences: Preferences,
         authorizeEmailAction: AuthorizeEmailAction) {

        self.fetchNotificationsAction = fetchNotificationsAction
        self.sessionActions = sessionActions
        self.preferences = preferences
        self.authorizeEmailAction = authorizeEmailAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Delay by one second to avoid hammering the backend with requests
        let periodicFetch = buildFetchNotificationsPeriodicAction(intervalInSeconds: 1)

        subscribeTo(periodicFetch, onNext: { _ in })
        subscribeTo(sessionActions.watchEmailAuthorization(), onComplete: self.onEmailAuthorization)
        subscribeTo(sessionActions.watchUser(), onNext: self.onUserChange)
        subscribeTo(authorizeEmailAction.getState(), onNext: self.onAuthorizeValue)
    }

    func runVerification(uuid: String) {
        authorizeEmailAction.run(uuid: uuid)
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

extension SignInAuthorizeEmailPresenter: NotificationsFetcher {}
