//
//  ChangePasswordEnterNewViewPresenter.swift
//  Muun
//
//  Created by Daniel Mankowski on 29/05/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import Foundation


enum ChangePasswordState {
    case inputPassword
    case passwordMatch
    case passwordDoesNotMatch
    case confirmPassword
}

protocol ChangePasswordNewViewPresenterDelegate: BasePresenterDelegate {
    func updateUi(state: ChangePasswordState)
}

class ChangePasswordNewViewPresenter<Delegate: ChangePasswordNewViewPresenterDelegate>:
    BasePresenter<Delegate> {

    func onInputPasswordStateChanged(firstPassword: String,
                                     secondPassword: String,
                                     isAgreeChangePasswordChecked: Bool) {
        let inputState = checkInputState(firstPassword: firstPassword,
                                         secondPassword: secondPassword,
                                         isAgreeChangePasswordChecked: isAgreeChangePasswordChecked)

        delegate.updateUi(state: inputState)
    }

    func isPasswordChangeAllowed(firstPassword: String,
                                 secondPassword: String,
                                 isAgreeChangePasswordChecked: Bool) -> Bool {
        let inputState = checkInputState(firstPassword: firstPassword,
                                         secondPassword: secondPassword,
                                         isAgreeChangePasswordChecked: isAgreeChangePasswordChecked)
        return inputState == .confirmPassword
    }

    private func checkInputState(firstPassword: String,
                                 secondPassword: String,
                                 isAgreeChangePasswordChecked: Bool) -> ChangePasswordState {
        let minimumPasswordLength = 8

        guard firstPassword.count >= minimumPasswordLength,
              secondPassword.count >= minimumPasswordLength else {
            return .inputPassword
        }

        guard firstPassword == secondPassword else {
            return .passwordDoesNotMatch
        }

        if isAgreeChangePasswordChecked {
            return .confirmPassword
        }

        return .passwordMatch
    }
}
