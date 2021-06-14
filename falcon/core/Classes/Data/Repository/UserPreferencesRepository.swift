//
//  UserPreferencesRepository.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 11/12/2020.
//

import Foundation
import RxSwift

public class UserPreferencesRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    public func watch() -> Observable<UserPreferences> {
        return preferences.watchObject(key: .userPreferences)
            // Use default values if we have none in storage
            .map { $0 ?? StoredUserPreferences() }
            .map { $0.toModel() }
    }

    public func update(_ prefs: UserPreferences) {
        preferences.set(object: StoredUserPreferences(prefs: prefs), forKey: .userPreferences)
    }
}

/*
 When adding a new field:
  * Always set a default value, make sure it matches what houston and apollo say
  * The fields must be var to ensure Codable can set the value

 Never change the names of properties since this is used for serialization.

 For complete instructions, see UserPreferences in common.
 */
private struct StoredUserPreferences: Codable {
    var receiveStrictMode: Bool?
    var seenNewHome: Bool?
    var seenLnurlFirstTime: Bool?

    init() {
    }

    init(prefs: UserPreferences) {
        self.receiveStrictMode = prefs.receiveStrictMode
        self.seenNewHome = prefs.seenNewHome
        self.seenLnurlFirstTime = prefs.seenLnurlFirstTime
    }

    func toModel() -> UserPreferences {
        return UserPreferences(
            receiveStrictMode: receiveStrictMode ?? false,
            seenNewHome: seenNewHome ?? false,
            seenLnurlFirstTime: seenLnurlFirstTime ?? false
        )
    }
}
