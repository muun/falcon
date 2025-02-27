//
//  RecoveryCodePrimingPresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 26/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//



protocol RecoveryCodePrimingPresenterDelegate: BasePresenterDelegate {
    func goToNextScreen(recoveryCode: RecoveryCode)
    func continueButtonIs(loading: Bool)
    func showStartRecoveryCodeSetupError()
}

class RecoveryCodePrimingPresenter<Delegate: RecoveryCodePrimingPresenterDelegate>: BasePresenter<Delegate> {
    let startRecoverySetup: StartRecoverCodeSetupAction
    var recoveryCode: RecoveryCode?

    init(delegate: Delegate,
         startRecoverySetupAction: StartRecoverCodeSetupAction) {
        self.startRecoverySetup = startRecoverySetupAction
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        recoveryCode = startRecoverySetup.run()
    }

    private func onStartRecoverySetupStateChanged(_ result: ActionState<Void>) {
        switch result.type {
        case .EMPTY, .LOADING: break
        case .VALUE:
            delegate.continueButtonIs(loading: false)
            // If recovery code is not present then there is a flow error and we can not continue.
            // This is unit tested also
            delegate.goToNextScreen(recoveryCode: recoveryCode!)
        case .ERROR:
            delegate.continueButtonIs(loading: false)
            delegate.showStartRecoveryCodeSetupError()
        }
    }

    func onContinueButtonTapped() {
        delegate.continueButtonIs(loading: true)
        subscribeTo(startRecoverySetup.getState(), onNext: onStartRecoverySetupStateChanged)
    }

    func retryTappedAfterError() {
        delegate.continueButtonIs(loading: true)
        recoveryCode = startRecoverySetup.run()
    }
}
