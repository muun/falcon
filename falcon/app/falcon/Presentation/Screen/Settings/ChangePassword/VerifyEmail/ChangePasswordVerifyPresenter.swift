//
//  ChangePasswordVerifyPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 29/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift
import core

protocol ChangePasswordVerifyPresenterDelegate: BasePresenterDelegate {
    func showLoading()
    func onEmailVerified()
}

class ChangePasswordVerifyPresenter<Delegate: ChangePasswordVerifyPresenterDelegate>: BasePresenter<Delegate> {

    private let sessionActions: SessionActions
    internal let fetchNotificationsAction: FetchNotificationsAction
    private let authorizeEmailAction: AuthorizeEmailAction

    init(delegate: Delegate,
         sessionActions: SessionActions,
         fetchNotificationsAction: FetchNotificationsAction,
         authorizeEmailAction: AuthorizeEmailAction) {
        self.sessionActions = sessionActions
        self.fetchNotificationsAction = fetchNotificationsAction
        self.authorizeEmailAction = authorizeEmailAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Delay by one second to avoid hammering the backend with requests
        let periodicFetch: Observable<Int> = buildFetchNotificationsPeriodicAction(intervalInSeconds: 1)

        subscribeTo(sessionActions.watchChangePasswordVerification(), onNext: self.onEmailAuthorization)
        subscribeTo(periodicFetch, onNext: { _ in })
    }

    private func onEmailAuthorization(_ result: Bool?) {
        if let emailVerification = result, emailVerification {
            delegate.onEmailVerified()
        }
    }

    func getUserEmail() -> String {
        // It's safe to assume that the user will have an email set-up by this point
        return sessionActions.getUser()?.email ?? ""
    }

    func runVerification(uuid: String) {
        delegate.showLoading()
        authorizeEmailAction.runChangePasswordVerification(uuid: uuid)
    }
}

extension ChangePasswordVerifyPresenter: NotificationsFetcher {}
