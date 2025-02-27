//
//  AppDelegate+Notification.swift
//  falcon
//
//  Created by Manu Herrera on 02/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import UserNotifications


extension AppDelegate {

    internal func handle(notification: [AnyHashable: Any],
                         completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /*
         The server is sending three different dictionaries as notifications, so we need to handle all of them 🤷‍♂️.
         1. notification["aps"["alert"]] = message // Visual Notification
         2. notification["message"] = message // Background notification
         3. notification["notification"["body"]] = message // Visual Notification
        */
        do {
            var notificationReport = getReportFromVisualNotification(notification)

            if notificationReport == nil {
                notificationReport = try getReportFromBackgroundNotification(completionHandler, notification)
            }

            notificationReport.map {
                _ = notificationProcessor.process(report: $0)
                    .subscribe(onCompleted: {
                        completionHandler(.newData)
                    }, onError: { err in
                        AnalyticsHelper.recordErrorToCrashlytics(err, additionalInfo: notification)
                        completionHandler(.failed)
                    })
            }

        } catch {
            AnalyticsHelper.recordErrorToCrashlytics(error, additionalInfo: notification)
            completionHandler(.failed)
        }

    }

    private func getReportFromBackgroundNotification(_ completionHandler: (UIBackgroundFetchResult) -> Void,
                                                     _ notification: [AnyHashable: Any]) throws -> NotificationReport? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601

        let notificationReportJson: NotificationReportJson

        if let message = notification["message"] as? String, let data = message.data(using: .utf8) {
            notificationReportJson = try decoder.decode(NotificationReportJson.self, from: data)
        } else {
            guard let notif = notification["notification"] as? [AnyHashable: Any],
                  let body = notif["body"] as? String,
                  let data = body.data(using: .utf8) else {
                Logger.log(.warn, "Failed to handle notification: \(notification)")
                completionHandler(.failed)
                return nil
            }
            notificationReportJson = try decoder.decode(NotificationReportJsonContainer.self,
                                                        from: data).message
        }

        return notificationReportJson.toModel(decrypter: operationMetadataDecrypter)
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
        // I will always want to open a visual notification if the user tapped on it.
        unhandledVisualNotification = userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(.info, "Message ID: \(messageID)")
        }

        let application = UIApplication.shared
        if application.applicationState == .active || application.applicationState == .inactive {
            // .active = user tapped the notification when the app was in foreground
            // .inactive = user tapped the notification when the app was in background
            // If the app is not terminated and we're showing mainWindow then we show the notification flow in that moment
            if window?.isKeyWindow == true {
                displayVisualNotificationFlow(userInfo)
            }
        }

        completionHandler()
    }

    func displayVisualNotificationFlow(_ userInfo: [AnyHashable: Any]) {
        unhandledVisualNotification = nil
        if let report = getReportFromVisualNotification(userInfo) {
            let preview = report.preview

            if let notification = preview.first {
                displayNotificationFlowIfAvailable(message: notification.message)
            } else {
                displayNotificationFlowFetchingDetailsFromBackend(report)
            }
        }
    }

    private func displayNotificationFlowFetchingDetailsFromBackend(_ report: NotificationReport) {
        DispatchQueue.global(qos: .userInteractive).async {
            // swiftlint:disable force_error_handling
            let notification = try? self.houstonService.fetchNotification(notificationId: report.maximumId)
                .toBlocking()
                .single()

            DispatchQueue.main.async {
                if let notification = notification {
                    self.displayNotificationFlowIfAvailable(message: notification.message)
                }
            }
        }
    }

    private func displayNotificationFlowIfAvailable(message: Notification.Message) {
        switch message {
        case .newOperation(let op):
            presentOpDetail(op: op.operation)
        default:
            return
        }
    }

    fileprivate func getNotificationReportLegacy(_ userInfo: [AnyHashable: Any]) -> NotificationReport? {
        do {
            if let aps = userInfo["aps"] as? [String: Any],
                let alert = aps["alert"] as? String,
                let data = alert.data(using: .utf8) {

                return try NotificationParser.parseReport(data, decrypter: operationMetadataDecrypter)
            }
        } catch {
            Logger.log(error: error)
        }

        return nil
    }

    fileprivate func getReportFromVisualNotification(_ userInfo: [AnyHashable: Any]) -> NotificationReport? {
        do {
            if let aps = userInfo["aps"] as? [String: Any],
               let alertReport = aps["alert"] as? [String: Any],
               let data = try? JSONSerialization.data(withJSONObject: alertReport, options: []) {
                return try NotificationParser.parseReport(data, decrypter: operationMetadataDecrypter)
            } else {
                return getNotificationReportLegacy(userInfo)
            }
        } catch {
            return nil
        }
    }

    fileprivate func presentOpDetail(op: Operation) {
        let detailVc = DetailViewController(operation: op)
        let detailNavController = UINavigationController(rootViewController: detailVc)
        let navController = getRootNavigationControllerOnMainWindow()
        navController?.present(detailNavController, animated: true)
    }

    internal func clearNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    internal func checkIfAppWasOpenByNotification(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // When the app launch after user tap on notification (originally was not running / not in background)
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {

            if UIApplication.shared.applicationState != .background {
                unhandledVisualNotification = userInfo
            } else {
                handle(notification: userInfo, completionHandler: { _ in })
            }
        }
    }

}
