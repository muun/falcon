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

    public func isAnonUser() -> Bool {
        guard let user = getUser() else {
            return true
        }

        return user.email == nil
    }

    // FIXME: This shouldn't be public
    public func watchAppState() -> Observable<Bool?> {
        return preferences.watchBool(key: .appInForeground).asObservable()
    }

    public func setDisplayFiatAsMain(for user: User) {
        preferences.set(value: (user.primaryCurrency != "BTC"), forKey: .displayFiatCurrencyAsMain)
    }

    func getUserEmail() -> String? {
        return preferences.string(forKey: .email)
    }

}
