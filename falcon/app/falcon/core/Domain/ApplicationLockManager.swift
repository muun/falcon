//
//  ApplicationLockManager.swift
//  falcon
//
//  Created by Manu Herrera on 22/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public class ApplicationLockManager {

    static let attempts = 3
    static let secondsInBackgroundBeforeShowingLockScreen = 10

    public enum PinCheck {
        case invalid(isUnrecoverableUser: Bool)
        case valid
        case noMoreAttempts
    }

    private let secureStorage: SecureStorage
    private let sessionRepository: SessionRepository
    private let logoutAction: LogoutAction
    private let userRepository: UserRepository
    private let preferences: Preferences

    init(secureStorage: SecureStorage,
         sessionRepository: SessionRepository,
         logoutAction: LogoutAction,
         userRepository: UserRepository,
         preferences: Preferences) {

        self.secureStorage = secureStorage
        self.sessionRepository = sessionRepository
        self.logoutAction = logoutAction
        self.userRepository = userRepository
        self.preferences = preferences
    }

    public var isShowingLockScreen: Bool = false
    var lastTimeActive: Double = 0

    public func firstLaunch() {
        // Secure storage isn't cleared when the app is uninstalled
        secureStorage.wipeAll()
        // Preferences aren't cleared when someone transfer their data onto a new iOS device
        preferences.wipeAll()
        // Create the data dir for libwallet
        LibwalletStorageHelper.ensureExists()
    }

    public func wipeDataAndLogOut() {
        logoutAction.run()
    }

    private func getSecondsInBackground() -> Int {
        return Int(Date().timeIntervalSince1970 - lastTimeActive)
    }

    public func shouldShowLockScreen() -> Bool {
        var hasPin: Bool = false

        do {
            hasPin = try sessionRepository.hasPin()
        } catch {
            Logger.fatal(error: error)
        }

        let showPinDueToInactivty = appWasTerminated()
            || getSecondsInBackground() > ApplicationLockManager.secondsInBackgroundBeforeShowingLockScreen

        return hasPin
            && showPinDueToInactivty
            && !isShowingLockScreen
    }

    public func isValid(pin: String) -> PinCheck {
        if userRepository.isUnrecoverableUser() {
            return isValidForUnrecoverableUser(pin: pin)
        }

        return isValidForUser(pin: pin)
    }

    public func resetNumberOfAttemptsAfterValidAuthMethod() throws {
        try sessionRepository.store(pinAttemptsLeft: ApplicationLockManager.attempts)
    }

    private func isValidForUser(pin: String) -> PinCheck {
        do {
            let isValid = try sessionRepository.getPin() == pin

            if isValid {

                try resetNumberOfAttemptsAfterValidAuthMethod()
                return .valid
            } else {
                let attemptsLeft = self.attemptsLeft() - 1

                if attemptsLeft == 0 {
                    wipeDataAndLogOut()
                    return .noMoreAttempts
                }

                try sessionRepository.store(pinAttemptsLeft: attemptsLeft)

                return .invalid(isUnrecoverableUser: false)
            }

        } catch {
            // If we cant check it, false it
            Logger.log(error: error)

            return .invalid(isUnrecoverableUser: false)
        }
    }

    /*
     Anon users can input their pin infinite times wrong, since we can't log out them because they would lose their
     funds.
     */
    private func isValidForUnrecoverableUser(pin: String) -> PinCheck {
        do {
            let isValid = try sessionRepository.getPin() == pin

            if isValid {
                return .valid
            } else {
                return .invalid(isUnrecoverableUser: true)
            }
        } catch {
            // If we cant check it, false it
            Logger.log(error: error)
            return .invalid(isUnrecoverableUser: true)
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

    public func recoverableUserHasAttemptsAlreadySpent() -> Bool {
        return !userRepository.isUnrecoverableUser()
            && attemptsLeft() < ApplicationLockManager.attempts
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
        // swiftlint:disable force_error_handling
        do {
            hasPin = try sessionRepository.hasPin()
        } catch {
            Logger.fatal(error: error)
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
