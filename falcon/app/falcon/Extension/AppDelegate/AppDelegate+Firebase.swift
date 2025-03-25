//
//  AppDelegate+Firebase.swift
//  falcon
//
//  Created by Manu Herrera on 02/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//


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

                self.logAbsentFCMTokenWhenHavingPushPermissions()
            }
        }
    }

    /**
     In order to send push notifications, we rely on FCM. If we have push notification permissions, we must have an FCM token;
     otherwise, we can assume there is a bug in either APNS or FCM preventing us from getting an FCM token. This logic is a best effort
     to detect cases in which we have notification permissions but do not have an FCM token.
     */
    private func logAbsentFCMTokenWhenHavingPushPermissions() {
        // Avoid logging twice.
        guard !fcmTokenHandlingAlreadyReported else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if !self.preferences.has(key: .gcmToken) {
                let hasAPNSToken = (Messaging.messaging().apnsToken != nil)
                Logger.log(.err, "FCMToken inconsistency: permission granted but fcmToken not received. has ApnsToken: \(hasAPNSToken)")
                return
            }
        }

        fcmTokenHandlingAlreadyReported = true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            return
        }
        // This callback is fired at each app startup and whenever a new token is generated.

        Logger.log(.info, "Firebase registration token: \(fcmToken)")

        fcmTokenAction.run(token: fcmToken)
        requestAPNSTokenOnlyAfterPermissionsApproval()
    }

}
