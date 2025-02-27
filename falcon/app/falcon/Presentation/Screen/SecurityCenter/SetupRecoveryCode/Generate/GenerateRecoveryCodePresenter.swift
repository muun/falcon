//
//  GenerateRecoveryCodePresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation


protocol GenerateRecoveryCodePresenterDelegate: BasePresenterDelegate {
}

class GenerateRecoveryCodePresenter<Delegate: GenerateRecoveryCodePresenterDelegate>: BasePresenter<Delegate> {

    private let preferences: Preferences

    init(delegate: Delegate, preferences: Preferences) {
        self.preferences = preferences
        super.init(delegate: delegate)
    }
}
