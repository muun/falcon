//
//  SignInWithRCPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 09/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift
import core
import Libwallet

protocol SignInWithRCPresenterDelegate: BasePresenterDelegate {
    func setLoading(_ isLoading: Bool)
    func recoveryCodeNotSetUp()
    func invalidRecoveryCodeVersion()
    func loggedIn()
    func needsEmailVerify(obfuscatedEmail: String)
    func showStaleRcError()
}

class SignInWithRCPresenter<Delegate: SignInWithRCPresenterDelegate>: BasePresenter<Delegate> {

    private let createRCLoginSessionAction: CreateRCLoginSessionAction
    private let logInWithRCAction: LogInWithRCAction
    private let preferences: Preferences
    private let fcmTokenAction: FCMTokenAction

    init(delegate: Delegate,
         createRCLoginSessionAction: CreateRCLoginSessionAction,
         logInWithRCAction: LogInWithRCAction,
         preferences: Preferences,
         fcmTokenAction: FCMTokenAction) {
        self.createRCLoginSessionAction = createRCLoginSessionAction
        self.logInWithRCAction = logInWithRCAction
        self.preferences = preferences
        self.fcmTokenAction = fcmTokenAction

        super.init(delegate: delegate)
    }

    var recoveryCode = ""

    override func setUp() {
        super.setUp()

        subscribeTo(logInWithRCAction.getState(), onNext: self.onLogInChange)
        subscribeTo(createRCLoginSessionAction.getState(), onNext: self.onCreateSessionChange)
    }

    func createSession(recoveryCode: String) {

        do {
            let rc = try RecoveryCode(code: recoveryCode)
            if rc.version == 1 {
                throw MuunError(Errors.invalidRCVersion)
            }
        } catch {
            delegate.invalidRecoveryCodeVersion()
            return
        }

        delegate.setLoading(true)
        self.recoveryCode = recoveryCode

        if getGcmToken() == "" {
            subscribeTo(fcmTokenAction.getValue().catchErrorJustReturn(()), onSuccess: { _ in
                self.createRCLoginSessionAction.run(gcmToken: self.getGcmToken(), recoveryCode: recoveryCode)
            })
        } else {
            createRCLoginSessionAction.run(gcmToken: self.getGcmToken(), recoveryCode: recoveryCode)
        }

    }

    func getGcmToken() -> String {
        return preferences.string(forKey: .gcmToken) ?? ""
    }

    private func onCreateSessionChange(_ result: ActionState<Challenge>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {
                if e.isKindOf(.recoveryCodeNotSetUp) {
                    delegate.recoveryCodeNotSetUp()
                } else {
                    handleError(e)
                }
            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            if let challenge = result.value {
                logInWithRCAction.run(challenge: challenge, recoveryCode: recoveryCode)
            }
        }
    }

    private func onLogInChange(_ value: ActionState<(hasEmailSetup: Bool, obfuscatedEmail: String?)>) {
        switch value.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = value.error {
                if e.isKindOf(.staleChallengeKey) {
                    delegate.showStaleRcError()
                } else {
                    handleError(e)
                }
            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            if let hasEmailSetup = value.value?.hasEmailSetup, hasEmailSetup, let email = value.value?.obfuscatedEmail {
                delegate.needsEmailVerify(obfuscatedEmail: email)
            } else {
                delegate.loggedIn()
            }
        }
    }

    enum Errors: Error {
        case invalidRCVersion
    }

}
