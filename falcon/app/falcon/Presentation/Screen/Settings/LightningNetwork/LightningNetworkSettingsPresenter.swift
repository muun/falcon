//
//  TurboChannelsPresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

import RxSwift

protocol LightningNetworkSettingsPresenterDelegate: BasePresenterDelegate {
    func setLoading(_ loading: Bool)
}

class LightningNetworkSettingsPresenter<Delegate: LightningNetworkSettingsPresenterDelegate>: BasePresenter<Delegate> {
    private let updateUserPreferences: UpdateUserPreferencesAction
    private let userPreferencesSelector: UserPreferencesSelector

    init(delegate: Delegate,
         updateUserPreferences: UpdateUserPreferencesAction,
         userPreferencesSelector: UserPreferencesSelector) {
        self.updateUserPreferences = updateUserPreferences
        self.userPreferencesSelector = userPreferencesSelector
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        let combined = Observable.combineLatest(
            userPreferencesSelector.watch(),
            updateUserPreferences.getState()
        )

        subscribeTo(combined, onNext: self.handleUpdateState)
    }

    func handleUpdateState(_ state: (UserPreferences, ActionState<Void>)) {
        let (_, action) = state

        switch action.type {
        case .EMPTY, .ERROR:
            delegate?.setLoading(false)
        case .LOADING:
            delegate?.setLoading(true)
        case .VALUE:
            break
        }
    }
}
