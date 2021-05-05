//
//  SyncAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public enum SignFlow: String {
    case recover
    case create
}

public class SyncAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let addressActions: AddressActions
    private let operationActions: OperationActions
    private let userRepository: UserRepository
    private let realTimeDataAction: RealTimeDataAction
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let fetchNotificationsAction: FetchNotificationsAction
    private let createFirstSessionAction: CreateFirstSessionAction
    private let refreshInvoices: RefreshInvoicesAction
    private let apiMigrationsManager: ApiMigrationsManager
    private let userPreferencesRepository: UserPreferencesRepository

    init(houstonService: HoustonService,
         addressActions: AddressActions,
         operationActions: OperationActions,
         userRepository: UserRepository,
         realTimeDataAction: RealTimeDataAction,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         fetchNotificationsAction: FetchNotificationsAction,
         createFirstSessionAction: CreateFirstSessionAction,
         refreshInvoices: RefreshInvoicesAction,
         apiMigrationsManager: ApiMigrationsManager,
         userPreferencesRepository: UserPreferencesRepository) {

        self.houstonService = houstonService
        self.addressActions = addressActions
        self.operationActions = operationActions
        self.realTimeDataAction = realTimeDataAction
        self.fetchNotificationsAction = fetchNotificationsAction
        self.createFirstSessionAction = createFirstSessionAction
        self.refreshInvoices = refreshInvoices
        self.apiMigrationsManager = apiMigrationsManager

        self.userRepository = userRepository
        self.nextTransactionSizeRepository = nextTransactionSizeRepository
        self.userPreferencesRepository = userPreferencesRepository

        super.init(name: "SyncAction")
    }

    public func run(signFlow: SignFlow, gcmToken: String, currencyCode: String) {

        do {
            if signFlow == .create { // is anon user
                _ = try createFirstSessionAction.run(gcmToken: gcmToken, currencyCode: currencyCode)

                runCompletable(createFirstSessionAction.getValue().asCompletable()
                    .andThen(
                        Completable.deferred({
                            self.runActions()
                            return self.buildAndRunSyncCompletable()
                        })
                ))
            } else {
                runActions()
                runCompletable(buildAndRunSyncCompletable())
            }
        } catch {
            Logger.fatal(error: error)
        }
    }

    private func runActions() {
        realTimeDataAction.run()
        fetchNotificationsAction.run()
    }

    private func buildAndRunSyncCompletable() -> Completable {
        return Completable.zip(
            realTimeDataAction.getValue().asCompletable(),
            operationActions.updateOperations(),
            fetchNextTransactionSize(),
            fetchUserInfo(),
            addressActions.syncPublicKeySet(),
            fetchNotificationsAction.getValue().asCompletable(),
            resetApiMigrations()
        ).andThen(
            // We need the public key set before the invoices refreshing action
            Completable.deferred({
                self.runRefreshInvoices()
            })
        )
    }

    private func resetApiMigrations() -> Completable {
        return Completable.deferred {
            self.apiMigrationsManager.reset()
            return Completable.empty()
        }
    }

    private func runRefreshInvoices() -> Completable {
        refreshInvoices.run()
        return refreshInvoices.getValue().asCompletable()
    }

    func fetchUserInfo() -> Completable {
        return houstonService.fetchUserInfo()
            .do(onSuccess: { (user, prefs) in
                self.userRepository.setUser(user)
                self.userPreferencesRepository.update(prefs)
            })
            .asCompletable()
    }

    func fetchNextTransactionSize() -> Completable {
        return houstonService.fetchNextTransactionSize()
            .do(onSuccess: { (data) in
                self.nextTransactionSizeRepository.setNextTransactionSize(data)
            })
            .asCompletable()
    }

}
