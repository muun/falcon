//
//  TaskRunner.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

typealias RunnableAsyncAction<T> = AsyncAction<T> & Runnable

public class TaskRunner {

    let syncExternalAddressesAction: SyncExternalAddresses
    let fetchNotificationsAction: FetchNotificationsAction
    var lastRun: Date?

    public init(syncExternalAddressesAction: SyncExternalAddresses,
                fetchNotificationsAction: FetchNotificationsAction) {
        self.syncExternalAddressesAction = syncExternalAddressesAction
        self.fetchNotificationsAction = fetchNotificationsAction
    }

    public func run() {

        let now = Date()
        if let lastRun = lastRun,
            lastRun.addingTimeInterval(60 * 60) > now {

            // If at least an hour hasn't elapsed since the last known run, skip it
            // If lastRun is nil it means the app just started and we should run
            return
        }

        lastRun = now

        // This isn't a critical action so delay to avoid stepping on other requests
        schedule(after: 2) {
            self.run(action: self.syncExternalAddressesAction)
        }

        // We only run this once since after that FCM should do the rest
        run(action: fetchNotificationsAction, retries: 0)
    }

    private func schedule(after: TimeInterval, cb: @escaping () -> Void) {
        _ = Scheduler.backgroundScheduler.scheduleRelative((), dueTime: after) { _ in
            cb()

            return BooleanDisposable(isDisposed: true)
        }
    }

    private func run<T>(action: RunnableAsyncAction<T>, retryInterval: TimeInterval = 1, retries: Int = 3) {

        func failed() {
            if retries == 0 {
                return
            }

            self.schedule(after: retryInterval) {
                self.run(action: action, retryInterval: retryInterval * 2, retries: retries - 1)
            }
        }

        _ = action.getValue()
            .do(onError: { _ in
                failed()
            })
            .subscribe()

        action.run()
    }

}
