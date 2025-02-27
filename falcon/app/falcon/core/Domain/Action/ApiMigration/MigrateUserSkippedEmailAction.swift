//
//  MigrateUserSkippedEmailAction.swift
//
//  Created by Lucas Serruya on 28/12/2022.
//

import Foundation
import RxSwift

public class MigrateUserSkippedEmailAction {
    let updateUserPreferencesAction: UpdateUserPreferencesAction
    let userLocalStorage: UserRepository

    init(updateUserPreferencesAction: UpdateUserPreferencesAction,
         userRepository: UserRepository) {
        self.updateUserPreferencesAction = updateUserPreferencesAction
        self.userLocalStorage = userRepository
    }

    func run() {
        if userLocalStorage.isEmailSkippedByPreference() {
            updateUserPreferencesAction.runPersistingLocallyEvenOnSyncFailure { prefs in
                prefs.copy(skippedEmailSetup: true)
            }
        }
    }
}
