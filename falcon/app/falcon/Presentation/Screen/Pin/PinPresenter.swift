//
//  PinPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 23/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//


import UIKit

protocol PinPresenterDelegate: BasePresenterDelegate {
    func pinRepeated(isValid: Bool)
    func pinChoosed()
    func displayAttemptsLeftHint(attemptsLeft: Int)
    func unlockSuccessful(authMethod: AuthMethod)
    func unlockUnsuccessful(attemptsLeft: Int, isUnrecoverableUser: Bool)
    func noMoreAttempts()
}

enum PinPresenterState {
    case choosePin
    case repeatPin
    case locked

    func loggingName() -> String {
        switch self {
        case .choosePin: return "choose"
        case .repeatPin: return "repeat"
        case .locked: return "locked"
        }
    }

    func pinTitle() -> String {
        switch self {
        case .choosePin: return L10n.PinPresenter.s1
        case .repeatPin: return L10n.PinPresenter.s2
        case .locked: return L10n.PinPresenter.s3
        }
    }

    func pinDescription() -> String {
        switch self {
        case .choosePin: return L10n.PinPresenter.s4
        case .repeatPin: return L10n.PinPresenter.s5
        case .locked: return ""
        }
    }
}

class PinPresenter<Delegate: PinPresenterDelegate>: BasePresenter<Delegate> {

    private var firstLoopPin = ""
    private var secondLoopPin = ""

    private let applicationLockManager: ApplicationLockManager
    private let syncAction: SyncAction
    private let fcmTokenAction: FCMTokenAction
    private let preferences: Preferences

    private var state: PinPresenterState

    init(delegate: Delegate,
         state: PinPresenterState,
         applicationLockManager: ApplicationLockManager,
         syncAction: SyncAction,
         fcmTokenAction: FCMTokenAction,
         preferences: Preferences) {

        self.state = state
        self.applicationLockManager = applicationLockManager
        self.syncAction = syncAction
        self.fcmTokenAction = fcmTokenAction
        self.preferences = preferences

        super.init(delegate: delegate)
    }

    func setUp(isExistingUser: Bool) {
        super.setUp()

        if shouldDisplayAttemptsLeftOnScreenStartup() {
            delegate.displayAttemptsLeftHint(attemptsLeft: getAttemptsLeft())
        }

        if state == .choosePin {
            let signFlow: SignFlow = (isExistingUser) ? .recover : .create
            let primaryCurrency = CurrencyHelper.currencyForLocale().code

            syncAction.run(signFlow: signFlow,
                           gcmToken: getGcmToken(),
                           currencyCode: primaryCurrency)
        }
    }

    func pinFinished(pin: String) {

        if state == .choosePin {
            firstLoopPin = pin

            state = .repeatPin
            delegate.pinChoosed()

        } else if state == .repeatPin {
            secondLoopPin = pin

            let isValid = secondLoopPin == firstLoopPin
            if isValid {
                applicationLockManager.set(pin: pin)
            }

            delegate.pinRepeated(isValid: isValid)

            secondLoopPin = ""

        } else if state == .locked {

            switch applicationLockManager.isValid(pin: pin) {
            case .valid:
                delegate.unlockSuccessful(authMethod: .pin)
            case .invalid(let isUnrecoverableUser):
                delegate.unlockUnsuccessful(attemptsLeft: getAttemptsLeft(),
                                            isUnrecoverableUser: isUnrecoverableUser)
            case .noMoreAttempts:
                delegate.noMoreAttempts()
            }
        }
    }

    func onBiometricsAuthFailed() {
        if applicationLockManager.getBiometricIdStatus() == true
            && applicationLockManager.recoverableUserHasAttemptsAlreadySpent() {
            delegate.displayAttemptsLeftHint(attemptsLeft: getAttemptsLeft())
        }
    }

    func onUserUnlockedAppSuccessfullyWithBiometrics() {
        do {
            try applicationLockManager.resetNumberOfAttemptsAfterValidAuthMethod()
        } catch {
            Logger.log(error: error)
        }
    }

    func resetChoose() {
        state = .choosePin
    }

    func getAttemptsLeft() -> Int {
        return applicationLockManager.attemptsLeft()
    }

    /// Get if biometrics is setted up.
    func getBiometricIdStatus() -> Bool {
        return applicationLockManager.getBiometricIdStatus() ?? false
    }

    func setBiometricIdStatus(_ status: Bool) {
        applicationLockManager.setBiometricIdStatus(status)
    }

    func getGcmToken() -> String? {
        return preferences.string(forKey: .gcmToken)
    }

    // When setting up the view if the user has biometrics we need to avoid displaying
    // attempts left under the biometrics alert. Otherwise we show the hint to users
    // that are not being affected by it since they are using biometrics. In that case we
    // show the hint as soon as biometrics fails
    private func shouldDisplayAttemptsLeftOnScreenStartup() -> Bool {
        return state == .locked
        && applicationLockManager.recoverableUserHasAttemptsAlreadySpent()
        && applicationLockManager.getBiometricIdStatus() != true
    }
}
