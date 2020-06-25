//
//  NotificationProcessor.swift
//  falcon
//
//  Created by Manu Herrera on 19/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift
import RxBlocking

public class NotificationProcessor {

    private let operationActions: OperationActions
    private let houstonService: HoustonService
    private let sessionRepository: SessionRepository
    private let sessionActions: SessionActions

    private let queue: DispatchQueue

    init(operationActions: OperationActions,
         houstonService: HoustonService,
         sessionRepository: SessionRepository,
         sessionActions: SessionActions) {
        self.operationActions = operationActions
        self.houstonService = houstonService
        self.sessionRepository = sessionRepository
        self.sessionActions = sessionActions

        self.queue = DispatchQueue(label: "notifications")
    }

    public func processReport(_ notifications: [Notification], maximumId: Int) -> Completable {

        let subject = BehaviorSubject.init(value: ())

        queue.async {
            do {
                _ = try self._process(notifications: notifications).toBlocking().materialize()

                let previousId = self.sessionRepository.getLastNotificationId()
                if previousId < maximumId {

                    let nextBatch = try self.fetchNotificationsAfter(previousId, retries: 5)
                    _ = try self._process(notifications: nextBatch).toBlocking().materialize()
                }

            } catch {
                Logger.log(error: error)
            }

            subject.onCompleted()
        }

        return subject.asObservable().ignoreElements()
    }

    func process(notifications: [Notification]) -> Completable {

        let subject = BehaviorSubject.init(value: ())

        queue.async {
            do {
                _ = try self._process(notifications: notifications).toBlocking().materialize()
            } catch {
                Logger.log(error: error)
            }

            subject.onCompleted()
        }

        return subject.asObservable().ignoreElements()
    }

    private func fetchNotificationsAfter(_ notificationId: Int, retries: Int) throws -> [Notification] {
        // The retries param is here because we are having a weird bug in the backend.
        // Will delete it once we fix the backend.
        let notifications = houstonService.fetchNotificationsAfter(notificationId: notificationId).toBlocking()

        switch notifications.materialize() {
        case .completed(let elements):
            if let notifications = elements.first {
                return notifications
            } else {
                Logger.log(.err, "Got completed but no elements")
            }

        case .failed(let elements, let error):
            if let notifications = elements.first {
                Logger.log(.err, "Got notifications and error too: \(error)")
                return notifications
            } else {
                Logger.log(error: error)
            }
        }

        if retries == 0 {
            throw MuunError(Errors.failedFetch(fromId: notificationId))
        } else {
            Logger.log(error: MuunError(Errors.failedFetch(fromId: notificationId)))
            return try fetchNotificationsAfter(notificationId, retries: retries - 1)
        }
    }

    private func _process(notifications: [Notification]) throws -> Completable {

        guard let firstNotification = notifications.first else {
            // If the array is empty, do nothing
            return Completable.empty()
        }

        var toProcess: [Notification]
        let previousId = sessionRepository.getLastNotificationId()
        if firstNotification.previousId > previousId {
            toProcess = try fetchNotificationsAfter(previousId, retries: 5)
        } else {
            toProcess = notifications
        }

        let results = toProcess
            .filter { $0.id > previousId }
            .map { notification in
                Completable.deferred { try self.process(notification: notification) }
                    .andThen(Single.just(notification.id))
                    .asObservable()
            }

        return Observable.concat(results)
            .do(onNext: self.sessionRepository.store(lastNotificationId:))
            .ignoreElements()
            .catchError { error in
                Logger.log(error: error)

                // We want the sequence to stop on error, but we don't want to bubble up
                return Completable.empty()
            }
            .andThen(self.confirmNotificationsDelivery(previous: previousId))
    }

    private func confirmNotificationsDelivery(previous id: Int?) -> Completable {

        return Completable.deferred {
            let newId = self.sessionRepository.getLastNotificationId()

            if newId != id {
                return self.houstonService.confirmNotificationsDeliveryUntil(notificationId: newId)
            } else {
                return Completable.empty()
            }
        }
    }

    // We can't split an enum and we can't reduce the number of notifications
    // so we disable the check
    // swiftlint:disable cyclomatic_complexity
    private func process(notification: Notification) throws -> Completable {

        let handler = try handlerFor(notification: notification)

        try verifyPermissions(handler: handler, notification: notification)
        try verifyOrigin(handler: handler, notification: notification)

        // This is a /just in case/ check, we should be catching this condition earlier
        let lastId = sessionRepository.getLastNotificationId()
        if lastId != notification.previousId {
            throw MuunError(Errors.missingPreviousNotification(notificationId: notification.id,
                                                               sessionUuid: notification.senderSessionUuid,
                                                               lastId: lastId))
        }

        return handler.process()
    }

    private func handlerFor(notification: Notification) throws -> NotificationHandler {

        switch notification.message {

        case .sessionAuthorized:
            return CallbackNotificationHandler(.BLOCKED_BY_EMAIL) {
                return self.sessionActions.emailAuthorized()
            }

        case .newOperation(let newOperation):
            return CallbackNotificationHandler(.LOGGED_IN) {
                self.operationActions.recieved(newOperation: newOperation)
            }

        case .operationUpdate(let operationUpdated):
            return CallbackNotificationHandler(.LOGGED_IN) {
                self.operationActions.operationUpdated(operationUpdated)
            }

        case .unknownMessage(let type):
            throw MuunError(Errors.unknownType(notificationId: notification.id,
                                               sessionUuid: notification.senderSessionUuid,
                                               type: type))

        case .newContact:
            return FutureCompatNotificationHandler()

        case .expiredSession:
            return FutureCompatNotificationHandler()

        case .updateContact:
            return FutureCompatNotificationHandler()

        case .updateAuthorizeChallenge:
            return FutureCompatNotificationHandler()

        case .verifiedEmail:
            return CallbackNotificationHandler(.LOGGED_IN) {
                return self.sessionActions.emailAuthorized()
            }

        case .completePairingAck:
            return FutureCompatNotificationHandler()

        case .addHardwareWallet:
            return FutureCompatNotificationHandler()

        case .withdrawalResult:
            return FutureCompatNotificationHandler()

        case .getSatelliteState:
            return FutureCompatNotificationHandler()

        }
    }

    private func verifyPermissions(handler: NotificationHandler, notification: Notification) throws {

        if let permission = handler.permission,
            !sessionActions.hasPermissionFor(status: permission) {

            throw MuunError(Errors.noPermission(notificationId: notification.id,
                                                sessionUuid: notification.senderSessionUuid))
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func verifyOrigin(handler: NotificationHandler, notification: Notification) throws {
        // TODO: We don't have the info to do this yet
    }

    enum Errors: Error {
        case noPermission(notificationId: Int, sessionUuid: String)
        case unknownOrigin(notificationId: Int, sessionUuid: String)
        case unknownType(notificationId: Int, sessionUuid: String, type: String)
        case missingPreviousNotification(notificationId: Int, sessionUuid: String, lastId: Int)
        case failedFetch(fromId: Int)
    }
}
