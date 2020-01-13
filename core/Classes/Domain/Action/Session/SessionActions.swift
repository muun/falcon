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

    func emailAuthorized() -> Completable {
        return Completable.deferred({
            self.sessionRepository.setStatus(.AUTHORIZED_BY_EMAIL)

            return Completable.empty()
        })
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

    public func watchHasRecoveryCode() -> Observable<Bool?> {
        return sessionRepository.watchHasRecoveryCode()
    }

    public func getPrimaryCurrency() -> String {
        return userRepository.getUser()?.primaryCurrency ?? "BTC"
    }
}
