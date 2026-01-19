//
//  DataDependencyContainer.swift
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
                KeychainRepository(keyPrefix: try container.resolve(tag: DataTags.secureStoragePrefix),
                                   group: try container.resolve(tag: DataTags.secureStorageGroup))
            }
            container.register(factory: SecureStorage.init)
            container.register(.singleton, factory: Preferences.init)

            container.register(factory: FeeWindowRepository.init)
            container.register(factory: UserRepository.init)
            container.register(factory: ExchangeRateWindowRepository.init)
            container.register(factory: KeysRepository.init)
            container.register(factory: NextTransactionSizeRepository.init)
            container.register(factory: SessionRepository.init)
            container.register(.singleton, factory: DebugRequestsRepository.init)
            container.register(.singleton, factory: DebugAnalyticsRepository.init)
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
            container.register(factory: FeatureFlagsRepository.init)
            container.register(factory: ReachabilityStatusRepository.init)
            container.register(.unique, factory: MUTimer.init)
            container.register(.singleton, factory: BackgroundTimesRepository.init)
            container.register { AppleDeviceCheckAdapter() as DeviceCheckAdapter }
            container.register(.weakSingleton, factory: LocaleTimeZoneProvider.init)
            container.register(.singleton, factory: ProcessInfoProvider.init)
            container.register(.singleton, factory: ReachabilityProvider.init)
            container.register(.singleton, factory: ConectivityCapabilitiesProvider.init)
            container.register(.weakSingleton, factory: HardwareCapabilitiesProvider.init)
            container.register(.weakSingleton, factory: StoreKitCapabilitiesProvider.init)
            container.register(.weakSingleton, factory: AppInfoProvider.init)
            container.register(.weakSingleton, factory: HardwareCapabilitiesProvider.init)
            container.register(.weakSingleton, factory: DeviceCheckDataProvider.init)
            container.register(factory: NotificationScheduler.init)
            container.register(.singleton, factory: ErrorReporter.init)
            container.register(.unique, factory: PingURLService.init)
            container.register(factory: HoustonService.init)
            container.register(.singleton, factory: WalletService.init)
            container.register(.singleton, factory: HttpClientSessionProvider.init)
            container.register(.singleton, factory: KeyProvider.init)
            if #available(iOS 13.0, *) {
                container.register(.singleton) { NfcSessionImpl() as NfcSession }
            }
        }
    }

}

extension DependencyContainer {
    // swiftlint:disable large_tuple
    @discardableResult public func register<T, A, B, C, D, E, F, G>(
        _ scope: ComponentScope = .shared,
        type: T.Type = T.self,
        tag: DependencyTagConvertible? = nil,
        factory: @escaping ((A, B, C, D, E, F, G)) throws -> T
    ) -> Definition<T, (A, B, C, D, E, F, G)> {
        return register(scope: scope,
                        type: type,
                        tag: tag,
                        factory: factory,
                        numberOfArguments: 7) { container, tag in
            try factory((container.resolve(tag: tag),
                         container.resolve(tag: tag),
                         container.resolve(tag: tag),
                         container.resolve(tag: tag),
                         container.resolve(tag: tag),
                         container.resolve(tag: tag),
                         container.resolve(tag: tag))) }
    }
}
