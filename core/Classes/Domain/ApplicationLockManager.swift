//
//  ApplicationLockManager.swift
//  falcon
//
//  Created by Manu Herrera on 22/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

public class ApplicationLockManager {

    static let attempts = 3
    static let secondsInBackgroundBeforeShowingLockScreen = 10

    public enum PinCheck {
        case invalid
        case valid
        case noMoreAttempts
    }

    private let secureStorage: SecureStorage
    private let sessionRepository: SessionRepository
    private let logoutAction: LogoutAction
    private let userRepository: UserRepository

    init(secureStorage: SecureStorage,
         sessionRepository: SessionRepository,
         logoutAction: LogoutAction,
         userRepository: UserRepository) {

        self.secureStorage = secureStorage
        self.sessionRepository = sessionRepository
        self.logoutAction = logoutAction
        self.userRepository = userRepository
    }

    public var isShowingLockScreen: Bool = false
    var lastTimeActive: Double = 0

    public func firstLaunch() {
        // Secure storage isn't cleared when the app is uninstalled
        secureStorage.wipeAll()
    }

    public func wipeDataAndLogOut() {
        logoutAction.run()
    }

    private func getSecondsInBackground() -> Int {
        return Int(Date().timeIntervalSince1970 - lastTimeActive)
    }

    public func shouldShowLockScreen() -> Bool {
        var hasPin: Bool = false

        if (try? sessionRepository.getPin()) != nil {
            hasPin = true
        }

        let showPinDueToInactivty = appWasTerminated()
            || getSecondsInBackground() > ApplicationLockManager.secondsInBackgroundBeforeShowingLockScreen

        return hasPin
            && showPinDueToInactivty
            && !isShowingLockScreen
    }

    public func isValid(pin: String) -> PinCheck {

        do {
            let isValid = try sessionRepository.getPin() == pin

            if isValid {

                // Reset the number of attempts when we got a valid pin
                try sessionRepository.store(pinAttemptsLeft: ApplicationLockManager.attempts)
                return .valid
            } else {
                let attemptsLeft = self.attemptsLeft() - 1

                if attemptsLeft == 0 {
                    wipeDataAndLogOut()
                    return .noMoreAttempts
                }

                try sessionRepository.store(pinAttemptsLeft: attemptsLeft)

                return .invalid
            }

        } catch {
            // If we cant check it, false it
            Logger.log(error: error)

            return .invalid
        }
    }

    public func attemptsLeft() -> Int {
        do {
            return try sessionRepository.getPinAttemptsLeft()
        } catch {
            Logger.log(error: error)
            return 0
        }
    }

    public func getBiometricIdStatus() -> Bool? {
        return sessionRepository.getBiometricIdStatus()
    }

    public func setBiometricIdStatus(_ status: Bool) {
        return sessionRepository.setBiometricIdStatus(status)
    }

    public func set(pin: String) {
        do {
            try sessionRepository.store(pin: pin)
            try sessionRepository.store(pinAttemptsLeft: ApplicationLockManager.attempts)
        } catch {
            Logger.log(error: error)
        }
    }

    public func appWillResignActive() {
        lastTimeActive = Date().timeIntervalSince1970
    }

    public func shouldStartSetUpPinFlow() -> Bool {
        // This should only happens if the user is logged in and doesnt have a pin code
        let isLoggedIn = userRepository.getUser() != nil
        var hasPin: Bool = false

        if (try? sessionRepository.getPin()) != nil {
            hasPin = true
        }

        return isLoggedIn
            && !hasPin
            && !isShowingLockScreen
    }

    private func appWasTerminated() -> Bool {
        // If the app is terminated, then Application Lock Manager will be instantiated once the app is reopen
        // causing lastTimeActive variable to be 0
        return lastTimeActive == 0
    }

}
