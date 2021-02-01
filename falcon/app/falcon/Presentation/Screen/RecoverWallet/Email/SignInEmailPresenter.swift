//
//  SignInEmailPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift
import core

protocol SignInEmailPresenterDelegate: BasePresenterDelegate {
    func sessionResponseReceived(sessionOk: CreateSessionOk)
    func setLoading(_ isLoading: Bool)
    func userNotRegistered()
    func invalidEmail()
}

class SignInEmailPresenter<Delegate: SignInEmailPresenterDelegate>: BasePresenter<Delegate> {

    private let createSessionAction: CreateSessionAction
    private let preferences: Preferences
    private let fcmTokenAction: FCMTokenAction

    init(delegate: Delegate,
         createSessionAction: CreateSessionAction,
         preferences: Preferences,
         fcmTokenAction: FCMTokenAction) {
        self.createSessionAction = createSessionAction
        self.preferences = preferences
        self.fcmTokenAction = fcmTokenAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(createSessionAction.getState(), onNext: self.onCreateSessionChange)
    }

    fileprivate func runSessionAction(email: String) {
        createSessionAction.run(email: email, gcmToken: getGcmToken())
    }

    func createSession(email: String) {
        delegate.setLoading(true)

        if getGcmToken() == "" {
            subscribeTo(fcmTokenAction.getValue().catchErrorJustReturn(()), onSuccess: { _ in
                self.runSessionAction(email: email)
            })
        } else {
            runSessionAction(email: email)
        }
    }

    func getGcmToken() -> String {
        return preferences.string(forKey: .gcmToken) ?? ""
    }

    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[^@ ]+@[^@ ]+[.][^@ ]*[A-Za-z0-9]$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: testStr)
    }

    private func onCreateSessionChange(_ result: ActionState<CreateSessionOk>) {
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
            if let value = result.value {
                if value.isExistingUser {
                    delegate.sessionResponseReceived(sessionOk: value)
                } else {
                    delegate.userNotRegistered()
                }
            }
        }
    }

    override func handleError(_ e: Error) {

        if e.isKindOf(.invalidEmail) {
            delegate.invalidEmail()
        } else if e.isKindOf(.emailNotRegistered) {
            delegate.userNotRegistered()
        } else {
            super.handleError(e)
        }

    }

}
