//
//  AppDelegate+Notification.swift
//  falcon
//
//  Created by Manu Herrera on 02/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import UserNotifications
import core

extension AppDelegate {

    internal func handle(notification: [AnyHashable: Any],
                         completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /*
         The server is sending three different dictionaries as notifications, so we need to handle all of them 🤷‍♂️.
         1. notification["aps"["alert"]] = message
         2. notification["message"] = message
         3. notification["notification"["body"]] = message
        */
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .customISO8601
            let report: NotificationReportJson

            if let aps = notification["aps"] as? [String: Any],
                let alert = aps["alert"] as? String,
                let data = alert.data(using: .utf8) {

                report = try decoder.decode(NotificationReportJsonContainer.self, from: data).message
            } else {
                if let message = notification["message"] as? String, let data = message.data(using: .utf8) {
                    report = try decoder.decode(NotificationReportJson.self, from: data)
                } else {
                    guard let notif = notification["notification"] as? [AnyHashable: Any],
                        let body = notif["body"] as? String,
                        let data = body.data(using: .utf8) else {
                            Logger.log(.warn, "Failed to handle notification: \(notification)")
                            completionHandler(.failed)
                            return
                    }
                    report = try decoder.decode(NotificationReportJsonContainer.self, from: data).message
                }
            }

            _ = notificationProcessor.process(report: report.toModel(decrypter: operationMetadataDecrypter))
                .subscribe(onCompleted: {
                    completionHandler(.newData)
                }, onError: { err in
                    AnalyticsHelper.recordErrorToCrashlytics(err, additionalInfo: notification)
                    completionHandler(.failed)
                })

        } catch {
            AnalyticsHelper.recordErrorToCrashlytics(error, additionalInfo: notification)
            completionHandler(.failed)
        }

    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // Receive displayed notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(.info, "Message ID: \(messageID)")
        }

        // Allow the alert to show if this is a locally produced notification
        if notification.request.identifier.starts(with: "local:") {
            completionHandler([.alert, .sound])
        } else {
            completionHandler([])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // This method is called once the user taps a notification

        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(.info, "Message ID: \(messageID)")
        }

        let application = UIApplication.shared

        if application.applicationState == .active || application.applicationState == .inactive {
            // .active = user tapped the notification when the app was in foreground
            // .inactive = user tapped the notification when the app was in background
            processNotification(userInfo)
        }

        completionHandler()
    }

    fileprivate func processNotification(_ userInfo: [AnyHashable: Any]) {
        if let report = getNotificationReport(userInfo) {
            let preview = report.preview
            if let notification = preview.first {
                switch notification.message {
                case .newOperation(let op):
                    presentOpDetail(op: op.operation)
                default:
                    return
                }
            }
            // If the notification doesnt have a preview we cannot know the operation id
            // Therefore touching on the notification will do absolutly nothing 🙃
        }
    }

    fileprivate func getNotificationReport(_ userInfo: [AnyHashable: Any]) -> NotificationReport? {
        do {
            if let aps = userInfo["aps"] as? [String: Any],
                let alert = aps["alert"] as? String,
                let data = alert.data(using: .utf8) {

                return try NotificationParser.parseReport(data, decrypter: operationMetadataDecrypter)
            }

        } catch {
            return nil
        }
        return nil
    }

    fileprivate func presentOpDetail(op: core.Operation) {
        let detailVc = DetailViewController(operation: op)
        let detailNavController = UINavigationController(rootViewController: detailVc)
        navController.present(detailNavController, animated: true)
    }

    internal func clearNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    internal func checkIfAppWasOpenByNotification(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // When the app launch after user tap on notification (originally was not running / not in background)
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {

            if UIApplication.shared.applicationState != .background {
                processNotification(userInfo)
            } else {
                handle(notification: userInfo, completionHandler: { _ in })
            }
        }
    }

}
