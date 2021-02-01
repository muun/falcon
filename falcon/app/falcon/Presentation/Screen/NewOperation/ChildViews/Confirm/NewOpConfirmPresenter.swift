//
//  NewOpConfirmPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 25/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

protocol NewOpConfirmPresenterDelegate: BasePresenterDelegate {
    func dataValidated(_ isValid: Bool)
}

class NewOpConfirmPresenter<Delegate: NewOpConfirmPresenterDelegate>: BasePresenter<Delegate> {

    private let feeState: FeeState

    init(delegate: Delegate, state: FeeState) {
        self.feeState = state
        super.init(delegate: delegate)
    }

    func validityCheck() {
        switch feeState {
        case .finalFee:
            delegate.dataValidated(true)
        default:
            delegate.dataValidated(false)
        }
    }

}
