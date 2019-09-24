//
//  LogoutAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 29/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

public class LogoutAction: AsyncAction<Void> {

    private let houstonService: HoustonService
    private let secureStorage: SecureStorage
    private let databaseCoordinator: DatabaseCoordinator
    private let preferences: Preferences

    init(houstonService: HoustonService,
         secureStorage: SecureStorage,
         databaseCoordinator: DatabaseCoordinator,
         preferences: Preferences) {

        self.houstonService = houstonService
        self.secureStorage = secureStorage
        self.databaseCoordinator = databaseCoordinator
        self.preferences = preferences

        super.init(name: "LogoutAction")
    }

    public func run(notifyHouston: Bool = true) {

        let completable: Completable
        if notifyHouston {
            // This has to run before since we need the auth token to be there
            completable = houstonService.notifyLogout()
        } else {
            completable = Completable.empty()
        }

        // Once the request is built, we can wipe everything
        preferences.wipeAll()
        secureStorage.wipeAll()
        try? databaseCoordinator.wipeAll()

        runCompletable(completable)
    }

}
