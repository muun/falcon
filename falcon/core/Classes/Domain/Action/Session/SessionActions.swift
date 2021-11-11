//
//  SessionActions.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class SessionActions {

    private let sessionRepository: SessionRepository
    private let userRepository: UserRepository
    private let keysRepository: KeysRepository
    private let exchangeRateWindowRepository: ExchangeRateWindowRepository
    private let secureStorage: SecureStorage
    private let preferences: Preferences

    init(repository: SessionRepository,
         userRepository: UserRepository,
         keysRepository: KeysRepository,
         exchangeRateWindowRepository: ExchangeRateWindowRepository,
         secureStorage: SecureStorage,
         preferences: Preferences) {
        self.sessionRepository = repository
        self.userRepository = userRepository
        self.keysRepository = keysRepository
        self.exchangeRateWindowRepository = exchangeRateWindowRepository
        self.secureStorage = secureStorage
        self.preferences = preferences
    }

    public func isLoggedIn() -> Bool {
        return sessionRepository.getStatus() == SessionStatus.LOGGED_IN
    }

    public func isFirstLaunch() -> Bool {
        // We determine that it's Falcon first launch when:
        // 1. Session is null or
        // 2. User is null or
        // 3. The user doesn't have the auth token in it's secure storage
        return sessionRepository.getStatus() == nil
            || userRepository.getUser() == nil
            || !hasAuthToken()
    }

    private func hasAuthToken() -> Bool {
        do {
            return try secureStorage.has(.authToken)
        } catch {
            return false
        }
    }

    public func watchEmailAuthorization() -> Completable {
        return sessionRepository.watchStatus()
            .filter { $0 == SessionStatus.AUTHORIZED_BY_EMAIL }
            .take(1)
            .ignoreElements()
    }

    public func watchUser() -> Observable<User?> {
        return userRepository.watchUser()
    }

    public func isEmailAuthorized() -> Bool {
        // TODO: This not compatible with non-recoverable users
        return hasPermissionFor(status: .LOGGED_IN)
    }

    func emailAuthorized() -> Completable {
        return Completable.deferred({
            self.setEmailAuthorized(true)
            return Completable.empty()
        })
    }

    func verifyPasswordChange(_ isVerified: Bool) -> Completable {
        return Completable.deferred({
            self.setVerifyPasswordChange(isVerified)
            return Completable.empty()
        })
    }

    func authorizeRcSignIn() -> Completable {
        return Completable.deferred({
            self.setAuthorizeRcSignIn(true)
            return Completable.empty()
        })
    }

    public func setVerifyPasswordChange(_ isVerified: Bool) {
        userRepository.setVerifyPasswordChange(isVerified: isVerified)
    }

    private func setAuthorizeRcSignIn(_ isAuthorized: Bool) {
        userRepository.setAuthorizeRcSignIn(isAuthorized: isAuthorized)
    }

    public func unauthorizeRcSignIn() {
        setAuthorizeRcSignIn(false)
    }

    public func unauthorizeEmail() {
        setEmailAuthorized(false)
    }

    func hasPermissionFor(status: SessionStatus) -> Bool {
        guard let currentStatus = sessionRepository.getStatus() else {
            return false
        }

        switch (status, currentStatus) {

        case (.CREATED, .CREATED),
             (.CREATED, .BLOCKED_BY_EMAIL),
             (.CREATED, .AUTHORIZED_BY_EMAIL),
             (.CREATED, .LOGGED_IN):
            return true

        case (.BLOCKED_BY_EMAIL, .BLOCKED_BY_EMAIL),
             (.BLOCKED_BY_EMAIL, .AUTHORIZED_BY_EMAIL),
             (.BLOCKED_BY_EMAIL, .LOGGED_IN):
            return true

        case (.AUTHORIZED_BY_EMAIL, .AUTHORIZED_BY_EMAIL),
             (.AUTHORIZED_BY_EMAIL, .LOGGED_IN):
            return true

        case (.LOGGED_IN, .LOGGED_IN):
            return true

        default:
            return false
        }
    }

    public func hasRecoveryCode() -> Bool {
        do {
            return try keysRepository.hasChallengeKey(type: .RECOVERY_CODE)
        } catch {
            // Default to true to avoid users double registering
            return true
        }
    }

    public func hasPasswordChallengeKey() -> Bool {
        do {
            return try keysRepository.hasChallengeKey(type: .PASSWORD)
        } catch {
            return false
        }
    }

    public func getUserEmail() -> String? {
        return userRepository.getUserEmail()
    }

    public func isAnonUser() -> Bool {
        return userRepository.isAnonUser()
    }

    public func getUser() -> User? {
        return userRepository.getUser()
    }

    public func setUser(_ user: User) {
        userRepository.setUser(user)
    }

    public func setUserEmail(_ email: String) {
        userRepository.setUserEmail(email)
    }

    private func setEmailAuthorized(_ isAuthorized: Bool) {
        guard let user = getUser() else {
            return
        }

        var updatedUser = user
        updatedUser.isEmailVerified = isAuthorized
        userRepository.setUser(updatedUser)
    }

    public func updateUserEmail() {
        if var updatedUser = getUser(), let email = userRepository.getUserEmailInPreferences() {
            // Update user email for sign ups
            updatedUser.email = email
            setUser(updatedUser)
        }
    }

    public func watchHasRecoveryCode() -> Observable<Bool?> {
        return sessionRepository.watchHasRecoveryCode()
    }

    public func getPrimaryCurrency() -> String {
        guard let user = userRepository.getUser() else {
            return "BTC"
        }
        guard let window = exchangeRateWindowRepository.getExchangeRateWindow() else {
            return "BTC"
        }
        return user.primaryCurrencyWithValidExchangeRate(window: window)
    }

    func exported(kit: ExportEmergencyKit) {
        guard let user = getUser() else {
            return
        }

        var newVersions = user.exportedKitVersions ?? []
        if !newVersions.contains(kit.version) {
            newVersions.append(kit.version)
        }

        var updatedUser = user
        updatedUser.emergencyKit = kit
        updatedUser.exportedKitVersions = newVersions
        userRepository.setUser(updatedUser)
    }

    public func hasExportedKeys() -> Bool {
        guard let user = getUser() else {
            return false
        }

        return user.hasExportedKeys ?? false
    }

    public func hasExportedEmergencyKit() -> Bool {
        guard let user = getUser() else {
            return false
        }

        return user.hasExportedEmergencyKit()
    }

    public func getEmergencyExportedAt() -> Date? {
        guard let user = getUser() else {
            return nil
        }

        return user.emergencyKitLastExportedDate
    }

    public func watchChangePasswordVerification() -> Observable<Bool?> {
        return userRepository.watchChangePasswordVerification()
    }

    public func watchRcSignInAuthorization() -> Observable<Bool?> {
        return userRepository.watchRcSignInAuthorization()
    }

    /**
        isEmailSkipped can be true either if:
        1. The skipped email preference is true OR
        2. The user has the recovery code setup and doesn't have the email setup
     */
    public func isEmailSkipped() -> Bool {
        if hasPasswordChallengeKey() {
            return false
        }

        let isEmailSkippedPreference = userRepository.isEmailSkippedByPreference()

        return isEmailSkippedPreference || (hasRecoveryCode() && !hasPasswordChallengeKey())
    }

    public func setEmailSkipped() {
        userRepository.setEmailSkipped()
    }
}
