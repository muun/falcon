//
//  TransactionListPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 04/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import core

protocol TransactionListPresenterDelegate: BasePresenterDelegate {
    func onOperationsChange(_ ops: LazyLoadedList<core.Operation>)
}

class TransactionListPresenter<Delegate: TransactionListPresenterDelegate>: BasePresenter<Delegate> {

    private var operations: LazyLoadedList<core.Operation> = LazyLoadedList()
    private let operationActions: OperationActions
    internal let fetchNotificationsAction: FetchNotificationsAction

    init(delegate: Delegate, operationActions: OperationActions, fetchNotificationsAction: FetchNotificationsAction) {
        self.operationActions = operationActions
        self.fetchNotificationsAction = fetchNotificationsAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Fetch every 10 seconds to check for new operations or updates
        let periodicFetch = buildFetchNotificationsPeriodicAction(intervalInSeconds: 10)

        subscribeTo(periodicFetch, onNext: { _ in })
        subscribeTo(operationActions.getOperationsLazy(), onNext: self.onOperationsChange)
    }

    private func onOperationsChange(_ result: LazyLoadedList<core.Operation>) {
        operations = result
        delegate.onOperationsChange(result)
    }

}

extension TransactionListPresenter: NotificationsFetcher {}
