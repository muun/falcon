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

    private let notificationProcessor: NotificationProcessor

    init(notificationProcessor: NotificationProcessor) {

        self.notificationProcessor = notificationProcessor

        super.init(name: "FetchNotificationsAction")
    }

    public func run() {
        runCompletable(notificationProcessor.poll())
    }

}
