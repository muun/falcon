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
    private let fulfillIncomingSwap: FulfillIncomingSwapAction
    private let realTimeDataAction: RealTimeDataAction

    private let queue: DispatchQueue

    init(operationActions: OperationActions,
         houstonService: HoustonService,
         sessionRepository: SessionRepository,
         sessionActions: SessionActions,
         fulfillIncomingSwap: FulfillIncomingSwapAction,
         realTimeDataAction: RealTimeDataAction
    ) {
        self.operationActions = operationActions
        self.houstonService = houstonService
        self.sessionRepository = sessionRepository
        self.sessionActions = sessionActions
        self.fulfillIncomingSwap = fulfillIncomingSwap
        self.realTimeDataAction = realTimeDataAction

        self.queue = DispatchQueue(label: "notifications")
    }

    public func process(report: NotificationReport) -> Completable {

        let subject = BehaviorSubject.init(value: ())

        queue.async {
            do {
                let previousId = self.sessionRepository.getLastNotificationId()

                var maxProcessedId = previousId
                var maxSeenId = 0
                var reportToProcess = report;

                // If we have a gap between the report and what we last processed, ignore the report
                // and start processing from the start of the gap. We'll refetch a bit of data, but it
                // makes for simple code.
                if reportToProcess.previousId > previousId {
                    reportToProcess = try self.fetchNotificationsAfter(previousId, retries: 5)
                }

                _ = try self._process(notifications: reportToProcess.preview).toBlocking().materialize()
                maxSeenId = max(maxSeenId, reportToProcess.maximumId);
                if let lastNotification = reportToProcess.preview.last {
                    maxProcessedId = max(lastNotification.id, maxProcessedId)
                }

                while maxProcessedId < maxSeenId {

                    reportToProcess = try self.fetchNotificationsAfter(maxProcessedId, retries: 5)
                    _ = try self._process(notifications: reportToProcess.preview).toBlocking().materialize()

                    maxSeenId = max(maxSeenId, reportToProcess.maximumId);
                    if let lastNotification = reportToProcess.preview.last {
                        maxProcessedId = max(lastNotification.id, maxProcessedId)
                    }
                }

            } catch {
                Logger.log(error: error)
            }

            subject.onCompleted()
        }

        return subject.asObservable().ignoreElements()
    }

    private func fetchNotificationsAfter(_ notificationId: Int, retries: Int) throws -> NotificationReport {
        // The retries param is here because we are having a weird bug in the backend.
        // Will delete it once we fix the backend.
        let report = houstonService.fetchNotificationReportAfter(notificationId: notificationId).toBlocking()

        switch report.materialize() {
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

        guard notifications.count > 0 else {
            // If the array is empty, do nothing
            return Completable.empty()
        }

        let previousId = sessionRepository.getLastNotificationId()

        let results = notifications
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
                let deviceInfo = DeviceUtils.deviceInfo()
                return self.houstonService.confirmNotificationsDeliveryUntil(
                    notificationId: newId,
                    deviceModel: deviceInfo.model,
                    osVersion: deviceInfo.osVersion,
                    appStatus: deviceInfo.appStatus
                )
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

        case .authorizeRcSignIn:
            return CallbackNotificationHandler(.BLOCKED_BY_EMAIL) {
                return self.sessionActions.authorizeRcSignIn()
            }

        case .newOperation(let newOperation):
            return CallbackNotificationHandler(.LOGGED_IN) {
                self.operationActions.received(newOperation: newOperation)
            }

        case .operationUpdate(let operationUpdated):
            return CallbackNotificationHandler(.LOGGED_IN) {
                self.operationActions.operationUpdated(operationUpdated)
            }

        case .fulfillIncomingSwap(let uuid):
            return CallbackNotificationHandler(.LOGGED_IN) {
                return self.fulfillIncomingSwap.run(uuid: uuid)
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
            return CallbackNotificationHandler(.LOGGED_IN) {
                self.sessionActions.verifyPasswordChange(true)
            }

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

        case .eventCommunication:
            // This is a UI only notification
            return CallbackNotificationHandler { [realTimeDataAction] in
                realTimeDataAction.run(forceUpdate: true)
                return realTimeDataAction.getValue().asCompletable()
            }

        case .noOp:
            return CallbackNotificationHandler {
                return Completable.empty()
            }
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
