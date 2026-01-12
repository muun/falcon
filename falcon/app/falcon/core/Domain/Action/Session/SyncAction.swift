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

    /**
     
    @param preservePinOnAccountCreation
     Controls whether to preserve the user's PIN during session
    creation
     
     This action handles both account creation and account sync. During account creation, we
     wipe all data (including PIN), but there's an edge case where the user has already set their
     PIN in the current session before wallet creation and we might forget the user pin in those
     cases.
     
     What changes between sync and create and sync is SignFlow which dependes on the param
     isExistingUser in the case of SyncPresneter. if isExistingUser is true we don't have a problem
     as the account will be synced instead of created.
    
     Usage scenarios:
     - Sync after account creation attempt in pinPresenter (syncPresneter#runSyncAction) - isExistingUser = false
        -> preservePinOnAccountCreation = true
     - Account creation pre pin set (PinPresenter#setup) - isExistingUser = false
        -> preservePinOnAccountCreation = false
     - Sync after login scenarios  (syncPresenter#runSyncAction) - isExistingUser = true
        -> the param doesn't matter in those cases and it will perform a sync instead of a creation.
     */
    public func run(
        signFlow: SignFlow,
        gcmToken: String?,
        currencyCode: String,
        preservePinOnAccountCreation: Bool = false
    ) {

        do {
            if signFlow == .create { // is anon user
                // This direct call is unsafe as this action could run multiple times and concurrently since it isn't protected by the runSingle logic. It doesn't have a bug currently because of how it's being called. Do not take this direct call aproach as a reference as it is wrong.
                _ = try createFirstSessionAction.run(
                    gcmToken: gcmToken,
                    currencyCode: currencyCode,
                    preservePin: preservePinOnAccountCreation
                )

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
            fetchNotificationsAction.getValue().catchErrorJustReturn(()).asCompletable(),
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
