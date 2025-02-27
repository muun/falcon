//
//  ApiMigrationAction.swift
//  Created by Federico Bond on 26/11/2020.
//

import Foundation
import RxSwift

public class ApiMigrationAction: AsyncAction<()> {

    private let apiMigrationsManager: ApiMigrationsManager

    init(apiMigrationsManager: ApiMigrationsManager) {
        self.apiMigrationsManager = apiMigrationsManager
        super.init(name: "ApiMigrationAction")
    }

    public func run() {
        runCompletable(Completable.deferred {
            try self.apiMigrationsManager.migrate()
            return Completable.empty()
        })
    }
}
