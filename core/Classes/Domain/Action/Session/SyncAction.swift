//
//  SyncAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class SyncAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let addressActions: AddressActions
    private let operationActions: OperationActions
    private let userRepository: UserRepository
    private let realTimeDataAction: RealTimeDataAction
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let fetchNotificationsAction: FetchNotificationsAction

    init(houstonService: HoustonService,
         addressActions: AddressActions,
         operationActions: OperationActions,
         userRepository: UserRepository,
         realTimeDataAction: RealTimeDataAction,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         fetchNotificationsAction: FetchNotificationsAction) {

        self.houstonService = houstonService
        self.addressActions = addressActions
        self.operationActions = operationActions
        self.realTimeDataAction = realTimeDataAction
        self.fetchNotificationsAction = fetchNotificationsAction

        self.userRepository = userRepository
        self.nextTransactionSizeRepository = nextTransactionSizeRepository

        super.init(name: "SyncAction")
    }

    public func run() {
        let comp = Completable.merge(
            realTimeDataAction.getValue().asCompletable(),
            operationActions.updateOperations(),
            fetchNextTransactionSize(),
            fetchUserInfo(),
            addressActions.syncPublicKeySet(),
            fetchNotificationsAction.getValue().asCompletable()
        )

        fetchNotificationsAction.run()
        realTimeDataAction.run()
        runCompletable(comp)
    }

    func fetchUserInfo() -> Completable {
        return houstonService.fetchUserInfo()
            .do(onSuccess: { (user) in
                self.userRepository.setUser(user)
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
