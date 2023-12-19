//
//  SignInWithRCVerifyEmailPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift
import core

protocol SignInWithRCVerifyEmailPresenterDelegate: BasePresenterDelegate {
    func signInCompleted()
    func emailExpired()
}

class SignInWithRCVerifyEmailPresenter<Delegate: SignInWithRCVerifyEmailPresenterDelegate>: BasePresenter<Delegate> {

    internal let fetchNotificationsAction: FetchNotificationsAction
    private let sessionActions: SessionActions
    private let authorizeRCLoginAction: AuthorizeRCLoginAction
    private let getKeySetAction: GetKeySetAction

    private var recoveryCode: String = ""

    init(delegate: Delegate,
         state: String,
         fetchNotificationsAction: FetchNotificationsAction,
         sessionActions: SessionActions,
         authorizeRCLoginAction: AuthorizeRCLoginAction,
         getKeySetAction: GetKeySetAction) {

        self.recoveryCode = state
        self.fetchNotificationsAction = fetchNotificationsAction
        self.sessionActions = sessionActions
        self.authorizeRCLoginAction = authorizeRCLoginAction
        self.getKeySetAction = getKeySetAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Delay by one second to avoid hammering the backend with requests
        let periodicFetch = buildFetchNotificationsPeriodicAction(intervalInSeconds: 1)

        subscribeTo(periodicFetch, onNext: { _ in })
        subscribeTo(sessionActions.watchRcSignInAuthorization(), onNext: self.onRcSignInAuthorization)
        subscribeTo(authorizeRCLoginAction.getState(), onNext: self.onAuthorizeValue)
        subscribeTo(getKeySetAction.getState(), onNext: self.onKeySetStored)
    }

    func runVerification(uuid: String) {
        sessionActions.unauthorizeRcSignIn()
        authorizeRCLoginAction.run(uuid: uuid)
    }

    private func onRcSignInAuthorization(_ result: Bool?) {
        if let result = result, result {
            getKeySetAction.run(recoveryCode: recoveryCode)
        }
    }

    private func onKeySetStored(value: ActionState<()>) {
        switch value.type {
        case .EMPTY, .LOADING:
            break
        case .VALUE:
            self.delegate.signInCompleted()
        case .ERROR:
            delegate.showMessage(L10n.SignInWithRCVerifyEmailPresenter.s1)
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

}

extension SignInWithRCVerifyEmailPresenter: NotificationsFetcher {}
