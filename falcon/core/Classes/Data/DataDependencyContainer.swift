//
//  DataDependencyContainer.swift
//  core
//
//  Created by Juan Pablo Civile on 31/05/2019.
//

import Foundation
import Dip
import GRDB

public extension DependencyContainer {

    enum DataTags: String, DependencyTagConvertible {
        case databaseUrl
        case secureStoragePrefix
        case secureStorageGroup
    }

    static func dataContainer() -> DependencyContainer {
        return DependencyContainer { container in

            container.register(.singleton) { () -> DatabaseQueue in
                let url: URL = try container.resolve(tag: DataTags.databaseUrl)
                return try DatabaseQueue(path: url.path)
            }

            container.register(factory: { UNUserNotificationCenter.current() })

            container.register(.singleton, factory: DatabaseCoordinator.init)

            container.register {
                SecureStorage(keyPrefix: try container.resolve(tag: DataTags.secureStoragePrefix),
                              group: try container.resolve(tag: DataTags.secureStorageGroup))
            }
            container.register(.singleton, factory: Preferences.init)

            container.register(factory: FeeWindowRepository.init)
            container.register(factory: UserRepository.init)
            container.register(factory: ExchangeRateWindowRepository.init)
            container.register(factory: KeysRepository.init)
            container.register(factory: NextTransactionSizeRepository.init)
            container.register(factory: SessionRepository.init)
            container.register(factory: OperationRepository.init)
            container.register(factory: PublicProfileRepository.init)
            container.register(factory: TaskRunner.init)
            container.register(factory: SubmarineSwapRepository.init)
            container.register(factory: BlockchainHeightRepository.init)
            container.register(factory: ForwardingPolicyRepository.init)
            container.register(factory: IncomingSwapRepository.init)
            container.register(factory: EmergencyKitRepository.init)
            container.register(factory: ApiMigrationsVersionRepository.init)
            container.register(factory: UserPreferencesRepository.init)
            container.register(factory: MinFeeRateRepository.init)
            container.register(factory: FeaturesFlagsRepository.init)

            container.register(factory: NotificationScheduler.init)
            container.register(.singleton, factory: ErrorReporter.init)

            container.register(factory: HoustonService.init)
        }
    }
}
