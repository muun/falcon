//
//  UpdateUserPreferenceAction.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 11/12/2020.
//

import Foundation
import RxSwift

public class UpdateUserPreferencesAction: AsyncAction<Void> {

    private let houstonService: HoustonService
    private let userPreferencesRepository: UserPreferencesRepository

    init(houstonService: HoustonService, userPreferencesRepository: UserPreferencesRepository) {
        self.houstonService = houstonService
        self.userPreferencesRepository = userPreferencesRepository
        super.init(name: "UpdateUserPreferenceAction")
    }

    public func run(_ mutator: @escaping (UserPreferences) -> UserPreferences) {
        runCompletable(
            userPreferencesRepository
                .watch()
                .take(1)
                .asSingle()
                .map(mutator)
                .flatMap { prefs -> Single<UserPreferences> in
                    return self.houstonService.updateUserPreferences(prefs)
                        .andThen(Single.just(prefs))
                }
                .flatMapCompletable { prefs in
                    self.userPreferencesRepository.update(prefs)
                    return Completable.empty()
                }
        )
    }

    public func runPersistingLocallyEvenOnSyncFailure(_ mutator: @escaping (UserPreferences) -> UserPreferences) {
        runCompletable(
            userPreferencesRepository
                .watch()
                .take(1)
                .asSingle()
                .map(mutator)
                .flatMap({ prefs in
                    self.userPreferencesRepository.update(prefs)
                    return Single.just(prefs)
                })
                .flatMapCompletable(houstonService.updateUserPreferences(_:))
        )
    }

    public func runOnlyLocally(_ mutator: @escaping (UserPreferences) -> UserPreferences) {
        runCompletable(
            userPreferencesRepository
                .watch()
                .take(1)
                .asSingle()
                .map(mutator)
                .flatMapCompletable({ prefs in
                    self.userPreferencesRepository.update(prefs)
                    return Completable.empty()
                })
        )
    }
}
