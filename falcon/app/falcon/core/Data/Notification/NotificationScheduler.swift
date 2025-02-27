//
//  NotificationScheduler.swift
//  Created by Federico Bond on 05/05/2021.
//

import Foundation
import UserNotifications

public class NotificationScheduler {

    enum NotificationType {
        case pending
        case failed
    }

    public let userNotificationCenter: UNUserNotificationCenter

    public init(userNotificationCenter: UNUserNotificationCenter) {
        self.userNotificationCenter = userNotificationCenter
    }

    private func generateId(_ type: NotificationType, _ paymentHash: Data) -> String {
        return "local:\(type):\(paymentHash.toHexString())"
    }

    public func notifyPending(paymentHash: Data, title: String, body: String) {

        Logger.log(.info, "Scheduling notification for pending lightning payment with hash \(paymentHash.toHexString())")

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let request = UNNotificationRequest(
            identifier: generateId(.pending, paymentHash),
            content: content,
            trigger: nil
        )

        userNotificationCenter.add(request) { error in
            if let error = error {
                Logger.log(error: error)
                // Nothing else we can do
            }
        }
    }

    public func notifyFailed(paymentHash: Data, title: String, body: String, at date: Date) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )

        let request = UNNotificationRequest(
            identifier: generateId(.failed, paymentHash),
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        )

        Logger.log(.info, "Scheduling notification for pending lightning payment with hash \(paymentHash.toHexString()) at \(date)")

        userNotificationCenter.add(request) { error in
            if let error = error {
                Logger.log(error: error)
                // Nothing else we can do
            }
        }
    }

    public func cancelNotifications(paymentHash: Data) {
        Logger.log(.info, "Canceling notifications for lightning payment from \(paymentHash.toHexString())")

        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [
            generateId(.pending, paymentHash),
            generateId(.failed, paymentHash)
        ])
    }

}
