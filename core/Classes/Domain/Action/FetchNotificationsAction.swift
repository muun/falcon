//
//  FetchNotificationsAction.swift
//  falcon
//
//  Created by Manu Herrera on 29/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public class FetchNotificationsAction: AsyncAction<()>, Runnable {

    private let houstonService: HoustonService
    private let sessionRepository: SessionRepository
    private let notificationProcessor: NotificationProcessor

    init(houstonService: HoustonService,
         sessionRepository: SessionRepository,
         notificationProcessor: NotificationProcessor) {

        self.houstonService = houstonService
        self.sessionRepository = sessionRepository
        self.notificationProcessor = notificationProcessor

        super.init(name: "FetchNotificationsAction")
    }

    public func run() {
        let notifId = sessionRepository.getLastNotificationId()
        let fetch = houstonService.fetchNotificationsAfter(notificationId: notifId)
            .flatMapCompletable(notificationProcessor.process)

        runCompletable(fetch)
    }

}
