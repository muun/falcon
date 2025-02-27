//
//  NotificationsFetcher.swift
//  falcon
//
//  Created by Manu Herrera on 08/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//


import RxSwift

protocol NotificationsFetcher: AnyObject {
    var fetchNotificationsAction: FetchNotificationsAction { get }

    func buildFetchNotificationsPeriodicAction(intervalInSeconds: Int) -> Observable<ActionState<()>>
}

extension NotificationsFetcher {

    // Call this method to create a periodic action to fetch notifications from the backend every
    // `n` seconds
    func buildFetchNotificationsPeriodicAction(intervalInSeconds: Int) -> Observable<ActionState<()>> {
        let periodicFetch: Observable<ActionState<()>> = Observable.interval(
            .seconds(intervalInSeconds),
            scheduler: Scheduler.backgroundScheduler
        ).do(onNext: { (param: Int) in
            self.fetchNotificationsAction.run()
        }).flatMap { _ in
            return self.fetchNotificationsAction.getState()
        }.map { actionState in
            try self.stopPollingIfSessionExpired(actionState)
            return actionState
        }

        return periodicFetch
    }

    private func stopPollingIfSessionExpired(_ actionState: ActionState<()>) throws {
        if let error = actionState.getError() as? MuunError,
           error.isKindOf(.sessionExpiredOnNotificationProcessor) {
            Logger.log(.err, "Stop polling notifications because of a session expired")

            throw error
        }
    }
}
