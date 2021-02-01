//
//  NotificationsFetcher.swift
//  falcon
//
//  Created by Manu Herrera on 08/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import core
import RxSwift

protocol NotificationsFetcher: class {
    var fetchNotificationsAction: FetchNotificationsAction { get }

    func buildFetchNotificationsPeriodicAction(intervalInSeconds: Int) -> Observable<Int>
}

extension NotificationsFetcher {

    // Call this method to create a periodic action to fetch notifications from the backend every `n` seconds
    func buildFetchNotificationsPeriodicAction(intervalInSeconds: Int) -> Observable<Int> {
        let periodicFetch: Observable<Int> = Observable.interval(
            .seconds(intervalInSeconds),
            scheduler: Scheduler.backgroundScheduler
        ).do(onNext: { _ in
            self.fetchNotificationsAction.run()
        })

        return periodicFetch
    }

}
