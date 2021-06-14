//
//  TaskRunner.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

typealias RunnableAsyncAction = AsyncAction<()> & Runnable

public class TaskRunner {

    let syncExternalAddressesAction: SyncExternalAddresses
    let fetchNotificationsAction: FetchNotificationsAction
    let refreshInvoicesAction: RefreshInvoicesAction

    public init(syncExternalAddressesAction: SyncExternalAddresses,
                fetchNotificationsAction: FetchNotificationsAction,
                refreshInvoicesAction: RefreshInvoicesAction) {
        self.syncExternalAddressesAction = syncExternalAddressesAction
        self.fetchNotificationsAction = fetchNotificationsAction
        self.refreshInvoicesAction = refreshInvoicesAction
    }

    public func run() {
        // This isn't a critical action so delay to avoid stepping on other requests
        schedule(after: .seconds(2)) {
            self.run(action: self.syncExternalAddressesAction)
        }
        // We keep a high stock of invoices, so no need to rush to refresh them
        schedule(after: .seconds(3)) {
            self.run(action: self.refreshInvoicesAction)
        }

        // We only run this once since after that FCM should do the rest
        run(action: fetchNotificationsAction, retries: 0)
    }

    private func schedule(after: DispatchTimeInterval, cb: @escaping () -> Void) {
        _ = Scheduler.backgroundScheduler.scheduleRelative((), dueTime: after) { _ in
            cb()

            return BooleanDisposable(isDisposed: true)
        }
    }

    private func run(action: RunnableAsyncAction, retryInterval: DispatchTimeInterval = .seconds(1), retries: Int = 3) {

        _ = action.getValue()
            .do(onError: { err in
                if retries == 0 {
                    return
                }

                let level: LogLevel
                if err.isNetworkError() {
                    level = .info
                } else {
                    level = .warn
                }

                Logger.log(level,
                           "Retrying action \(action.`self`().description) due to error \(err.localizedDescription)")

                self.schedule(after: retryInterval) {
                    self.run(action: action, retryInterval: retryInterval.duplicate(), retries: retries - 1)
                }
            })
            .subscribe()

        action.run()
    }

}

fileprivate extension DispatchTimeInterval {

    func duplicate() -> DispatchTimeInterval {
        switch self {
        case .microseconds(let d):
            return .microseconds(2 * d)
        case .milliseconds(let d):
            return .milliseconds(2 * d)
        case .nanoseconds(let d):
            return .nanoseconds(2 * d)
        case .seconds(let d):
            return .seconds(2 * d)
        case .never:
            return .never
        @unknown default:
            Logger.log(.err, "Failed to duplicate interval \(self)")
            return self
        }
    }

}
