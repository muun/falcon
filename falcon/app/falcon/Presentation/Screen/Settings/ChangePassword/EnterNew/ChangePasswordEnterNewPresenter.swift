//
//  ChangePasswordEnterNewPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import RxSwift


protocol ChangePasswordEnterNewPresenterDelegate: BasePresenterDelegate {
    func setLoading(_ isLoading: Bool)
    func passwordChanged()
}

class ChangePasswordEnterNewPresenter<Delegate: ChangePasswordEnterNewPresenterDelegate>: BasePresenter<Delegate> {

    private let finishPasswordAction: FinishPasswordChangeAction

    init(delegate: Delegate, finishPasswordAction: FinishPasswordChangeAction) {
        self.finishPasswordAction = finishPasswordAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(finishPasswordAction.getState(), onNext: self.onFinishPasswordChange)
    }

    func finishPasswordChange(password: String, updateUuid: String) {
        finishPasswordAction.run(password: password, uuid: updateUuid)
    }

    private func onFinishPasswordChange(_ result: ActionState<()>) {
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
            delegate.passwordChanged()
        }
    }

}
