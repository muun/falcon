//
//  ApiMigrationsManager.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 25/11/2020.
//

import Foundation
import RxSwift

public class ApiMigrationsManager {

    private let apiMigrationsVersionRepository: ApiMigrationsVersionRepository

    private var migrations = [Int: () throws -> ()]()

    private var maxVersion: Int = 0

    public init(
        apiMigrationsVersionRepository: ApiMigrationsVersionRepository,
        fetchSwapServerKeyAction: FetchSwapServerKeyAction,
        migrateFingerprintsAction: MigrateFingerprintsAction,
        migrateUserSkippedEmail: MigrateUserSkippedEmailAction) {

        self.apiMigrationsVersionRepository = apiMigrationsVersionRepository

        registerMigration(version: 1, action: fetchSwapServerKeyAction.run)
        registerMigration(version: 2, action: migrateFingerprintsAction.run)
        // redo migrate fingerprints migration because it did not have proper error handling the first time
        registerMigration(version: 3, action: migrateFingerprintsAction.run)
        registerMigration(version: 4, action: migrateUserSkippedEmail.run)
    }

    private func registerMigration(version: Int, action: @escaping () throws -> ()) {
        assert(version == maxVersion + 1)
        migrations[version] = action
        maxVersion = version
    }

    public func migrate() throws {
        if !hasPending() {
            return
        }

        let nextVersion = apiMigrationsVersionRepository.get() + 1
        for versionToApply in nextVersion...maxVersion {
            // The key should always exist, so use ! to crash loudly if that's not the case
            try migrations[versionToApply]!()
            apiMigrationsVersionRepository.set(version: versionToApply)
        }
    }

    public func reset() {
        apiMigrationsVersionRepository.set(version: maxVersion)
    }

    public func hasPending() -> Bool {
        return apiMigrationsVersionRepository.get() < maxVersion
    }
}
