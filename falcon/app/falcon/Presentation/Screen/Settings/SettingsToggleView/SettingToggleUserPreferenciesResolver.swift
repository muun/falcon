//
//  SettingToggleUserPreferenciesResolver.swift
//  Muun
//
//  Created by Lucas Serruya on 04/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation

import RxSwift

class SettingToggleUserPreferenciesResolver {
    private let updateUserPreferences: UpdateUserPreferencesAction
    private let userPreferencesSelector: UserPreferencesSelector

    init(updateUserPreferences: UpdateUserPreferencesAction,
         userPreferencesSelector: UserPreferencesSelector) {
        self.updateUserPreferences = updateUserPreferences
        self.userPreferencesSelector = userPreferencesSelector
    }

    func setUpPreferencesListeners() -> Observable<(UserPreferences, ActionState<Void>)> {
        let combined = Observable.combineLatest(
            userPreferencesSelector.watch(),
            updateUserPreferences.getState()
        )

        return combined
    }

    func updateSetting(mutator: @escaping (UserPreferences) -> UserPreferences) {
        updateUserPreferences.run(mutator)
    }
}
