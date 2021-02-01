//
//  SignUpPasswordPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift
import core

protocol SignUpPasswordPresenterDelegate: BasePresenterDelegate {}

class SignUpPasswordPresenter<Delegate: SignUpPasswordPresenterDelegate>: BasePresenter<Delegate> {

    func isValidPassword(_ text: String) -> Bool {
        return text.count >= 8
    }

    func passwordsMatch(first: String, second: String) -> Bool {
        return first == second
    }
}
