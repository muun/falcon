//
//  ConfirmRecoveryCodePresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

protocol FinishRecoveryCodeSetupPresenterDelegate: BasePresenterDelegate {

    func challengeSuccess()
    func challengeFailed()

}

class FinishRecoveryCodeSetupPresenter<Delegate: FinishRecoveryCodeSetupPresenterDelegate>: BasePresenter<Delegate> {

    fileprivate let recoveryCode: RecoveryCode
    fileprivate let setupChallengeAction: SetupChallengeAction
    fileprivate let preferences: Preferences

    init(delegate: Delegate,
         state: RecoveryCode,
         setupChallengeAction: SetupChallengeAction,
         preferences: Preferences) {
        self.recoveryCode = state
        self.setupChallengeAction = setupChallengeAction
        self.preferences = preferences
        super.init(delegate: delegate)
    }

    func confirm() {
        subscribeTo(setupChallengeAction.getValue(), onSuccess: setupSuccess)

        setupChallengeAction.run(type: .RECOVERY_CODE, userInput: recoveryCode.description)
    }

    private func setupSuccess() {
        delegate.challengeSuccess()
    }

    override func handleError(_ e: Error) {
        delegate.challengeFailed()
    }

}
