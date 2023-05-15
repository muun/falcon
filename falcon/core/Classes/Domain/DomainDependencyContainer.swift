//
//  DomainDependencyContainer.swift
//  core
//
//  Created by Juan Pablo Civile on 31/05/2019.
//

import Foundation
import Dip

public extension DependencyContainer {

    static func domainContainer(data: DependencyContainer) -> DependencyContainer {
        return DependencyContainer { container in
            container.collaborate(with: data)

            // Lock manager really really needs to be a singleton
            container.register(.singleton, factory: ApplicationLockManager.init)

            container.register(.singleton, factory: NotificationProcessor.init)

            // Actions should always be singletons
            container.register(.singleton, factory: FetchNotificationsAction.init)
            container.register(.singleton, factory: CreateSessionAction.init)
            container.register(.singleton, factory: LogInAction.init)
            container.register(.singleton, factory: CompatLogInAction.init)
            container.register(.singleton, factory: RequestChallengeAction.init)
            container.register(.singleton, factory: SetUpPasswordAction.init)
            container.register(.singleton) {
                SessionActions(repository: $0,
                               userRepository: $1,
                               keysRepository: $2,
                               exchangeRateWindowRepository: $3,
                               secureStorage: $4,
                               preferences: $5,
                               updateUserPreferences: try container.resolve(),
                               userPreferencesSelector: try container.resolve())
            }
            container.register(.singleton, factory: AddressActions.init)
            container.register(.singleton) {
                OperationActions(operationRepository: $0,
                                 houstonService: $1,
                                 nextTransactionSizeRepository: $2,
                                 feeWindowRepository: $3,
                                 keysRepository: $4,
                                 verifyFulfillable: $5,
                                 notificationScheduler: try container.resolve())
            }
            container.register(.singleton, factory: BalanceActions.init)
            container.register(.singleton, factory: CurrencyActions.init)
            container.register(.singleton) {
                RealTimeDataAction(houstonService: $0,
                                   feeWindowRepository: $1,
                                   exchangeRateWindowRepository: $2,
                                   blockchainHeightRepository: $3,
                                   forwardingPoliciesRepository: $4,
                                   minFeeRateRepository: $5,
                                   featureFlagsRepository: try container.resolve())
            }
            container.register(.singleton, factory: FCMTokenAction.init)
            container.register(.singleton, factory: SyncExternalAddresses.init)
            container.register(.singleton, factory: FeeCalculatorAction.init)
            container.register(.singleton, factory: LogoutAction.init)
            container.register(.singleton, factory: SetupChallengeAction.init)
            container.register(.singleton, factory: StartRecoverCodeSetupAction.init)
            container.register(.singleton, factory: FinishRecoverCodeSetupAction.init)
            container.register(.singleton, factory: BuildChallengeSetupAction.init)
            container.register(.singleton, factory: SupportAction.init)
            container.register(.singleton, factory: ChangeCurrencyAction.init)
            container.register(.singleton, factory: VerifyEmailSetupAction.init)
            container.register(.singleton, factory: AuthorizeEmailAction.init)
            container.register(.singleton, factory: AuthorizeRCLoginAction.init)
            container.register(.singleton, factory: SubmarineSwapAction.init)
            container.register(.singleton, factory: BIP70Action.init)
            container.register(.singleton, factory: CreateFirstSessionAction.init)
            container.register(.singleton, factory: StartEmailSetupAction.init)
            container.register(.singleton, factory: OperationMetadataDecrypter.init)
            container.register(.singleton, factory: SignChallengeWithUserKeyAction.init)
            container.register(.singleton, factory: ReportEmergencyKitExportedAction.init)
            container.register(.singleton, factory: BeginPasswordChangeAction.init)
            container.register(.singleton, factory: FinishPasswordChangeAction.init)
            container.register(.singleton, factory: LogInWithRCAction.init)
            container.register(.singleton, factory: CreateRCLoginSessionAction.init)
            container.register(.singleton, factory: StoreKeySetAction.init)
            container.register(.singleton, factory: GetKeySetAction.init)
            container.register(.singleton, factory: CreateInvoiceAction.init)
            container.register(.singleton, factory: CreateBitcoinURIAction.init)
            container.register(.singleton, factory: RefreshInvoicesAction.init)
            container.register(.singleton, factory: FulfillIncomingSwapAction.init)
            container.register(.singleton, factory: FetchSwapServerKeyAction.init)
            container.register(.singleton, factory: MigrateFingerprintsAction.init)
            container.register(.singleton, factory: MigrateUserSkippedEmailAction.init)
            container.register(.singleton, factory: ApiMigrationAction.init)
            container.register(.singleton, factory: UpdateUserPreferencesAction.init)
            container.register(.singleton, factory: VerifyFulfillableAction.init)
            container.register(.singleton, factory: LNURLWithdrawAction.init)

            container.register(.singleton, factory: UserSelector.init)
            container.register(.singleton, factory: EmergencyKitDataSelector.init)
            container.register(.singleton, factory: UserPreferencesSelector.init)
            container.register(.singleton, factory: UserActivatedFeaturesSelector.init)
            container.register(.singleton, factory: FeatureFlagsSelector.init)

            container.register(.singleton, factory: ApiMigrationsManager.init)

            container.register(.singleton) {
                SyncAction(houstonService: $0,
                           addressActions: $1,
                           operationActions: $2,
                           userRepository: $3,
                           realTimeDataAction: $4,
                           nextTransactionSizeRepository: $5,
                           fetchNotificationsAction: try container.resolve(),
                           createFirstSessionAction: try container.resolve(),
                           refreshInvoices: try container.resolve(),
                           apiMigrationsManager: try container.resolve(),
                           userPreferencesRepository: try container.resolve())
            }
        }
    }
}
