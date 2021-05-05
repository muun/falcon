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

    internal func configureFirebase() {
        AnalyticsHelper.configure()
        // This client id needs to be hardwired here, since it can't be in the info.plist schemes because apple rejects
        // the build in that case
        GIDSignIn.sharedInstance().clientID = "31549017632-edq72gjasgvfem953m1a4qvk86muhjb2.apps.googleusercontent.com"

        Messaging.messaging().delegate = self
        AnalyticsHelper.setAnalyticsCollection(enabled: true)
        UNUserNotificationCenter.current().delegate = self

        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            if status == .authorized {
                // Attempt registration for remote notifications
                if !UIApplication.shared.isRegisteredForRemoteNotifications {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    internal func setApnsToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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
        }

    }

}
