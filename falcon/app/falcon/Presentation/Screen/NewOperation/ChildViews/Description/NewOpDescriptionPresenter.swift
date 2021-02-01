//
//  NewOpDescriptionPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 25/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

protocol NewOpDescriptionPresenterDelegate: BasePresenterDelegate {
    func userDidChangeDescription(_ isValid: Bool)
}

class NewOpDescriptionPresenter<Delegate: NewOpDescriptionPresenterDelegate>: BasePresenter<Delegate> {

    private let data: NewOperationStateAmount

    init(delegate: Delegate, state: NewOperationStateAmount) {
        self.data = state

        super.init(delegate: delegate)
    }

    func validityCheck(_ text: String) {
        let textIsEmpty = text.trimmingCharacters(in: .whitespaces).isEmpty
        delegate.userDidChangeDescription(!textIsEmpty)
    }

}
