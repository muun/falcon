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
    private let secureStorage: SecureStorage

    init(repository: SessionRepository,
         userRepository: UserRepository,
         keysRepository: KeysRepository,
         secureStorage: SecureStorage) {
        self.sessionRepository = repository
        self.userRepository = userRepository
        self.keysRepository = keysRepository
        self.secureStorage = secureStorage
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
            .first()
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

    public func isAnonUser() -> Bool {
        return userRepository.isAnonUser()
    }

    public func getUser() -> User? {
        return userRepository.getUser()
    }

    public func setUser(_ user: User) {
        userRepository.setUser(user)
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
        if var updatedUser = getUser(), let email = userRepository.getUserEmail() {
            // Update user email for sign ups
            updatedUser.email = email
            setUser(updatedUser)
        }
    }

    public func watchHasRecoveryCode() -> Observable<Bool?> {
        return sessionRepository.watchHasRecoveryCode()
    }

    public func getPrimaryCurrency() -> String {
        return userRepository.getUser()?.primaryCurrency ?? "BTC"
    }

    public func setDisplayFiatAsMain(for user: User) {
        userRepository.setDisplayFiatAsMain(for: user)
    }

    func setEmergencyKitExported(date: Date) {
        guard let user = getUser() else {
            return
        }

        var updatedUser = user
        updatedUser.emergencyKitLastExportedDate = date
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
}
