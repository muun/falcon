//
//  EmailPrimingPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 28/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import core

protocol EmailPrimingPresenterDelegate: BasePresenterDelegate {}

class EmailPrimingPresenter<Delegate: EmailPrimingPresenterDelegate>: BasePresenter<Delegate> {

    private let sessionActions: SessionActions
    private var wasEmailJustSkipped = false

    init(delegate: Delegate, sessionActions: SessionActions) {
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    func isEmailSkipped() -> Bool {
        return sessionActions.isEmailSkipped()
    }

    func skipEmail() {
        sessionActions.setEmailSkipped()
    }

}
