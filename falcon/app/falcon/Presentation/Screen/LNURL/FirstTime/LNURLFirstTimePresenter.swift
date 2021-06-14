//
//  LNURLFirstTimePresenter.swift
//  falcon
//
//  Created by Federico Bond on 10/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import core

protocol LNURLFirstTimePresenterDelegate: BasePresenterDelegate {

}

class LNURLFirstTimePresenter<Delegate: LNURLFirstTimePresenterDelegate>: BasePresenter<Delegate> {

    private let updateUserPreferencesAction: UpdateUserPreferencesAction

    init(delegate: Delegate, updateUserPreferencesAction: UpdateUserPreferencesAction) {
        self.updateUserPreferencesAction = updateUserPreferencesAction
        super.init(delegate: delegate)
    }

    func didTapContinue() {
        updateUserPreferencesAction.run { (prefs) -> UserPreferences in
            prefs.copy(seenLnurlFirstTime: true)
        }
    }

}
