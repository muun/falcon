//
//  SyncPresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift


protocol SyncDelegate: BasePresenterDelegate {
    func onSyncFinished()
    func syncFailed()
    func goToHome()
    func presentUnverifiedRecoveryCodeWarning()
    func dismissUnverifiedRecoveryCodeWarning()
}

class SyncPresenter<Delegate: SyncDelegate>: BasePresenter<Delegate> {

    private var syncAction: SyncAction
    private var preferences: Preferences
    private var signFlow: SignFlow
    private var syncAttemptsLeft = 2
    private var hasUserAcknowledgedIsUsingAnUnverifiedRecoveryCode = false

    init(delegate: Delegate, state: Bool, syncAction: SyncAction, preferences: Preferences) {

        self.signFlow = (state) ? .recover : .create
        self.syncAction = syncAction
        self.preferences = preferences

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(syncAction.getState(), onNext: self.onResponse)
    }

    private func onResponse(_ result: ActionState<Void>) {
        switch result.type {

        case .EMPTY:
            print()
        case .ERROR:
            preferences.set(value: "failed", forKey: .syncStatus)

            if syncAttemptsLeft > 0 {
                syncAttemptsLeft -= 1
                runSyncAction()
            } else {
                Logger.log(error: result.error!)
                delegate.syncFailed()
            }

        case .LOADING:
            print()

        case .VALUE:
            preferences.set(value: "success", forKey: .syncStatus)

            delegate.onSyncFinished()
        }
    }

    func runSyncAction() {
        syncAction.run(
            signFlow: signFlow,
            gcmToken: preferences.string(forKey: .gcmToken),
            currencyCode: CurrencyHelper.currencyForLocale().code
        )
    }

    func onReadyForHome() {
        if hasUserLoggedInWithAnUnverifiedRecoveryCodeAndDidNotAcknowledgedTheIssue() {
            delegate.presentUnverifiedRecoveryCodeWarning()
        } else {
            delegate.goToHome()
        }
    }

    func onUserAcknowledgeRecoveryCodeUnverified() {
        hasUserAcknowledgedIsUsingAnUnverifiedRecoveryCode = true
        delegate.dismissUnverifiedRecoveryCodeWarning()
    }

    func hasUserLoggedInWithAnUnverifiedRecoveryCodeAndDidNotAcknowledgedTheIssue() -> Bool {
        return preferences.bool(forKey: .hasResolvedARcChallenge)
        && !preferences.bool(forKey: .hasRecoveryCode)
        && !hasUserAcknowledgedIsUsingAnUnverifiedRecoveryCode
    }
}
