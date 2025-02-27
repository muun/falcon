//
//  SignUpEmailPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift


protocol SignUpEmailPresenterDelegate: BasePresenterDelegate {
    func responseOkReceived()
    func emailAlreadyUsed()
    func setLoading(_ isLoading: Bool)
    func invalidEmail()
}

class SignUpEmailPresenter<Delegate: SignUpEmailPresenterDelegate>: BasePresenter<Delegate> {

    private let startEmailSetupAction: StartEmailSetupAction
    private let fcmTokenAction: FCMTokenAction
    private let requestChallengeAction: RequestChallengeAction
    private let sessionActions: SessionActions
    private var email: String = ""

    init(delegate: Delegate,
         startEmailSetupAction: StartEmailSetupAction,
         fcmTokenAction: FCMTokenAction,
         requestChallengeAction: RequestChallengeAction,
         sessionActions: SessionActions) {
        self.startEmailSetupAction = startEmailSetupAction
        self.fcmTokenAction = fcmTokenAction
        self.requestChallengeAction = requestChallengeAction
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()
        subscribeTo(requestChallengeAction.getState(), onNext: self.onRequestChallengeChange)
        subscribeTo(startEmailSetupAction.getState(), onNext: self.onStartEmailSetupChange)
    }

    func requestChallenge(email: String) {
        self.email = email
        requestChallengeAction.run(type: ChallengeType.USER_KEY.rawValue)
    }

    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[^@ ]+@[^@ ]+[.][^@ ]*[A-Za-z0-9]$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: testStr)
    }

    private func onStartEmailSetupChange(_ result: ActionState<()>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {
                handleError(e)

            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            sessionActions.setUserEmail(email)
            sessionActions.unauthorizeEmail()

            delegate.responseOkReceived()
        }
    }

    override func handleError(_ e: Error) {

        if e.isKindOf(.invalidEmail) {
            delegate.invalidEmail()
        } else if e.isKindOf(.emailAlreadyUsed) {
            delegate.emailAlreadyUsed()
        } else {
            super.handleError(e)
        }

    }

    private func onRequestChallengeChange(_ result: ActionState<Challenge?>) {
        switch result.type {

        case .EMPTY:
            delegate.setLoading(false)

        case .ERROR:
            if let e = result.error {
                handleError(e)

            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setLoading(true)

        case .VALUE:
            if let value = result.value, let challenge = value {
                startEmailSetupAction.run(email: email, challenge: challenge)
            }
        }
    }

}
