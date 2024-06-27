//
//  FCMTokenAction.swift
//  falcon
//
//  Created by Manu Herrera on 20/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class FCMTokenAction: AsyncAction<()>, Runnable {

    private let houstonService: HoustonService
    private let preferences: Preferences
    private let sessionActions: SessionActions
    private let timer: MUTimer
    private let failureModeRetryInSeconds: TimeInterval = 30

    public init(houstonService: HoustonService,
                preferences: Preferences,
                sessionActions: SessionActions,
                timer: MUTimer) {
        self.houstonService = houstonService
        self.preferences = preferences
        self.sessionActions = sessionActions
        self.timer = timer

        super.init(name: "FCMTokenAction")
    }

    fileprivate func runAgainIfSyncedTokenIsNotTheLastOne(syncedToken: String) {
        // if a Token has been retrieved during paranoid mode and it is not synced, sync again.
        if let stringFromStorage = self.preferences.string(forKey: .gcmToken),
           stringFromStorage != syncedToken {
            self.run(token: stringFromStorage, runFromFailureMode: false)
        }
    }

    /**
     Runned from TaskRunner.
     */
    func run() {
        // This if is to avoid users who never has permissions or has the token synced from running by mistake.
        if preferences.has(key: .gcmToken) && !preferences.bool(forKey: .gcmTokenSynced) {
            self.runOnFailureMode()
        }
    }

    /**
     Attempt to sync FCMToken with houston. If the token is not successfully synced it will enter in failure mode.
     Failure mode attempts to send the token again every 15 seconds.
     In case of killing the app with a syncing error the app will sync with the old fcm token when waking up. If a new fcm token arrives
     while we are already syncing, that token will be processed by runAgainIfSyncedTokenIsNotTheLastOne.
     */
    public func run(token: String,
                    runFromFailureMode: Bool = false) {
        // This must be run here because the implementation of runSingle() ignores calls if the 
        // asyncAction is already running. Otherwise, incoming tokens will be lost.

        // Prevent tokens coming from FCM to be overwritten by tokens from failure mode.
        // Tokens coming from FCM are fresh are FCM is the source of truth.
        if !runFromFailureMode {
            self.preferences.set(value: token, forKey: .gcmToken)
        }

        var syncedToken: String?
        let single = Single.deferred { () -> Single<()> in
            guard self.sessionActions.isLoggedIn() else {
                return Single.just(())
            }

            // Firebase token callback runs this action on every startup.
            // As we already are in failure mode we are ignoring that manual call but keeping
            // the new token. That way as soon as the failure mode ends the last FCMToken will be synced
            // by #runAgainIfSyncedTokenIsNotTheLastOne.
            if self.shouldAvoidADirectCallDueToFailureMode(runFromFailureMode) {
                return Single.just(())
            }

            self.preferences.set(value: false, forKey: .gcmTokenSynced)
            syncedToken = token

            return self.houstonService.updateGcmToken(gcmToken: token)
        }.do(onSuccess: { completion in
            self.preferences.set(value: true, forKey: .gcmTokenSynced)
            self.stopFailureMode()
            // Avoid race conditions between FCM callbacks and failure mode. 
            // The dispatch is to make sure we are leaving time to the async action to change the
            // state into success, otherwise the async action ignores the new run.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // This value will always be there, it is being saved above.
                // If this value is not there anymore unit tests will start failing.
                syncedToken.map {
                    self.runAgainIfSyncedTokenIsNotTheLastOne(syncedToken: $0)
                }
            }
        }, onError: { error in
            self.preferences.set(value: false, forKey: .gcmTokenSynced)
            self.enterFailureMode()
        })

        runSingle(single)
    }

    @objc private func runOnFailureMode() {
        if let token = preferences.string(forKey: .gcmToken) {
            run(token: token, runFromFailureMode: true)
        } else {
            Logger.log(.err, "TokenSyncing in failure mode but there is no token in preferences")
        }
    }

    private func stopFailureMode() {
        self.timer.stop()
    }

    private func enterFailureMode() {
        timer.stop()
        timer.start(timeInterval: failureModeRetryInSeconds,
                         target: self,
                         selector: #selector(self.runOnFailureMode),
                         repeats: true)
    }

    private func shouldAvoidADirectCallDueToFailureMode(_ runFromFailureMode: Bool) -> Bool {
        return !runFromFailureMode
        && preferences.has(key: .gcmTokenSynced) // On the first run ever the value is not there.
        && !preferences.bool(forKey: .gcmTokenSynced)
    }
}
