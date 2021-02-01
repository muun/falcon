//
//  SessionExpiredPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 01/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

protocol SessionExpiredPresenterDelegate: BasePresenterDelegate {

}

class SessionExpiredPresenter<Delegate: SessionExpiredPresenterDelegate>: BasePresenter<Delegate> {

    let logoutAction: LogoutAction

    init(delegate: Delegate, logoutAction: LogoutAction) {
        self.logoutAction = logoutAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        logoutAction.run()
    }

}
