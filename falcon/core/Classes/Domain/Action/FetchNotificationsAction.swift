//
//  FetchNotificationsAction.swift
//  falcon
//
//  Created by Manu Herrera on 29/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

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
        runCompletable(
            houstonService.fetchNotificationReportAfter(notificationId: notifId)
                    .flatMapCompletable(notificationProcessor.process(report:))
        )
    }

}
