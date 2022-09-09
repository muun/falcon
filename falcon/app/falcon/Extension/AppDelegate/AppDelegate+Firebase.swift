//
//  AppDelegate+Firebase.swift
//  falcon
//
//  Created by Manu Herrera on 02/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import core
import GoogleSignIn
import Firebase

extension AppDelegate {
    func configureFirebase() {
        AnalyticsHelper.configure()

        Messaging.messaging().delegate = self
        AnalyticsHelper.setAnalyticsCollection(enabled: true)
        UNUserNotificationCenter.current().delegate = self

        requestAPNSTokenOnlyAfterPermissionsApproval()
    }

    func setApnsToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    fileprivate func requestAPNSTokenOnlyAfterPermissionsApproval() {
        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            if status == .authorized {
                // Attempt registration for remote notifications
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            return
        }
        // This callback is fired at each app startup and whenever a new token is generated.

        Logger.log(.info, "Firebase registration token: \(fcmToken)")

        preferences.set(value: fcmToken, forKey: .gcmToken)
        if sessionActions.isLoggedIn() {
            fcmTokenAction.run(token: fcmToken)
            requestAPNSTokenOnlyAfterPermissionsApproval()
        }
    }

}
