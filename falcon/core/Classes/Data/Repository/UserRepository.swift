//
//  UserRepository.swift
//  falcon
//
//  Created by Manu Herrera on 12/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class UserRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func setUser(_ user: User) {
        preferences.set(object: user, forKey: .user)
    }

    // FIXME: This shouldn't be public
    public func watchUser() -> Observable<User?> {
        return preferences.watchObject(key: .user)
    }

    // FIXME: This shouldn't be public
    public func getUser() -> User? {
        return preferences.object(forKey: .user)
    }

    public func isUnrecoverableUser() -> Bool {
        guard let user = getUser() else {
            return true
        }

        return !user.hasPasswordChallengeKey && !user.hasRecoveryCodeChallengeKey
    }

    // FIXME: This shouldn't be public
    public func watchAppState() -> Observable<Bool?> {
        return preferences.watchBool(key: .appInForeground)
    }

    func setUserEmail(_ email: String) {
        preferences.set(value: email, forKey: .email)
    }

    func getUserEmailInPreferences() -> String? {
        return preferences.string(forKey: .email)
    }

    func getUserEmail() -> String? {
        return getUser()?.email
    }

    func setVerifyPasswordChange(isVerified: Bool) {
        preferences.set(value: isVerified, forKey: .passwordChangeVerification)
    }

    func watchChangePasswordVerification() -> Observable<Bool?> {
        return preferences.watchBool(key: .passwordChangeVerification)
    }

    func setAuthorizeRcSignIn(isAuthorized: Bool) {
        preferences.set(value: isAuthorized, forKey: .rcSignInAuthorization)
    }

    func watchRcSignInAuthorization() -> Observable<Bool?> {
        return preferences.watchBool(key: .rcSignInAuthorization)
    }

    func isEmailSkippedByPreference() -> Bool {
        return preferences.bool(forKey: .isEmailSkipped)
    }

    func setEmailSkipped() {
        preferences.set(value: true, forKey: .isEmailSkipped)
    }

}
