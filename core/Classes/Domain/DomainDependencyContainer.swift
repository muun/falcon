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
            container.register(.singleton, factory: RequestChallengeAction.init)
            container.register(.singleton, factory: SignUpAction.init)
            container.register(.singleton, factory: SessionActions.init)
            container.register(.singleton, factory: AddressActions.init)
            container.register(.singleton, factory: OperationActions.init)
            container.register(.singleton, factory: CurrencyActions.init)
            container.register(.singleton, factory: RealTimeDataAction.init)
            container.register(.singleton, factory: FCMTokenAction.init)
            container.register(.singleton, factory: SyncExternalAddresses.init)
            container.register(.singleton, factory: FeeCalculatorAction.init)
            container.register(.singleton, factory: LogoutAction.init)
            container.register(.singleton, factory: SetupChallengeAction.init)
            container.register(.singleton, factory: SupportAction.init)
            container.register(.singleton, factory: ChangeCurrencyAction.init)
            container.register(.singleton, factory: VerifyAuthorizeAction.init)
            container.register(.singleton, factory: SubmarineSwapAction.init)
            container.register(.singleton, factory: LappListAction.init)
            container.register(.singleton, factory: BIP70Action.init)
            container.register(.singleton, factory: SendEncryptedKeysEmailAction.init)

            container.register(.singleton, factory: UserSelector.init)
            container.register(.singleton, factory: EncryptedUserKeySelector.init)
            container.register(.singleton, factory: EncryptedMuunKeySelector.init)

            container.register(.singleton) {
                SyncAction(houstonService: $0,
                           addressActions: $1,
                           operationActions: $2,
                           userRepository: $3,
                           realTimeDataAction: $4,
                           nextTransactionSizeRepository: $5,
                           fetchNotificationsAction: try container.resolve())
            }
        }
    }
}
