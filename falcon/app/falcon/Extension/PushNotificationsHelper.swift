//
//  PushNotificationsHelper.swift
//  falcon
//
//  Created by Manu Herrera on 01/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UserNotifications

enum PushNotificationsHelper {

    static func getPushNotificationAuthorizationStatus(status: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in

            // We almost always use this from UI code so push to the main thread always
            DispatchQueue.main.async {
                status(settings.authorizationStatus)
            }
        })
    }

}
