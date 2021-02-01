//
//  PinPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 23/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import core
import UIKit

protocol PinPresenterDelegate: BasePresenterDelegate {
    func pinRepeated(isValid: Bool)
    func pinChoosed()
    func unlockSuccessful()
    func unlockUnsuccessful(attemptsLeft: Int, isAnonUser: Bool)
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

        if state == .choosePin {
            let signFlow: SignFlow = (isExistingUser) ? .recover : .create
            let primaryCurrency = CurrencyHelper.currencyForLocale().code

            if getGcmToken() == "" {
                subscribeTo(fcmTokenAction.getValue().catchErrorJustReturn(()), onSuccess: { _ in
                    self.syncAction.run(signFlow: signFlow, gcmToken: self.getGcmToken(), currencyCode: primaryCurrency)
                })
            } else {
                syncAction.run(signFlow: signFlow, gcmToken: getGcmToken(), currencyCode: primaryCurrency)
            }
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
                delegate.unlockSuccessful()
            case .invalid(let isAnonUser):
                delegate.unlockUnsuccessful(attemptsLeft: getAttemptsLeft(), isAnonUser: isAnonUser)
            case .noMoreAttempts:
                delegate.noMoreAttempts()
            }
        }

    }

    func resetChoose() {
        state = .choosePin
    }

    func getAttemptsLeft() -> Int {
        return applicationLockManager.attemptsLeft()
    }

    func getBiometricIdStatus() -> Bool {
        return applicationLockManager.getBiometricIdStatus() ?? false
    }

    func setBiometricIdStatus(_ status: Bool) {
        applicationLockManager.setBiometricIdStatus(status)
    }

    func getGcmToken() -> String {
        return preferences.string(forKey: .gcmToken) ?? ""
    }

}
