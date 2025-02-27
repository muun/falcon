//
//  ConfirmRecoveryCodePresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation


protocol FinishRecoveryCodeSetupPresenterDelegate: BasePresenterDelegate {
    func challengeSuccess()
    func showFinishErrorSetupError()
    func finishButtonIs(loading: Bool)
}

class FinishRecoveryCodeSetupPresenter<Delegate: FinishRecoveryCodeSetupPresenterDelegate>: BasePresenter<Delegate> {

    fileprivate let recoveryCode: RecoveryCode
    fileprivate let finishRecoveryCodeSetupAction: FinishRecoverCodeSetupAction

    init(delegate: Delegate,
         state: RecoveryCode,
         finishRecoveryCodeSetupAction: FinishRecoverCodeSetupAction) {
        self.recoveryCode = state
        self.finishRecoveryCodeSetupAction = finishRecoveryCodeSetupAction
        super.init(delegate: delegate)
    }

    func confirm() {
        subscribeTo(finishRecoveryCodeSetupAction.getState(), onNext: onStartRecoverySetupStateChanged)
        finishRecoveryCodeSetupAction.run(type: .RECOVERY_CODE,
                                          recoveryCode: recoveryCode)
    }

    private func onStartRecoverySetupStateChanged(_ result: ActionState<Void>) {
        switch result.type {
        case .EMPTY, .LOADING: break
        case .VALUE:
            setupSuccess()
        case .ERROR:
            delegate.finishButtonIs(loading: false)
            delegate.showFinishErrorSetupError()
        }
    }

    private func setupSuccess() {
        delegate.challengeSuccess()
    }

    func retryTappedAfterError() {
        delegate.finishButtonIs(loading: true)
        finishRecoveryCodeSetupAction.run(type: .RECOVERY_CODE,
                                          recoveryCode: recoveryCode)
    }
}
