//
//  TurboChannelsPresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

import RxSwift
import Libwallet

protocol OnchainSettingsPresenterDelegate: BasePresenterDelegate {
    func update(hoursToActivation: Int)
    func update(enabled: Bool)
    func setLoading(_ loading: Bool)
}

class OnchainSettingsPresenter<Delegate: OnchainSettingsPresenterDelegate>: BasePresenter<Delegate> {

    private let updateUserPreferences: UpdateUserPreferencesAction
    private let userPreferencesSelector: UserPreferencesSelector
    private let userActivatedFeatureSelector: UserActivatedFeaturesSelector
    private let blockheightRepository: BlockchainHeightRepository

    init(delegate: Delegate,
         updateUserPreferences: UpdateUserPreferencesAction,
         userPreferencesSelector: UserPreferencesSelector,
         userActivatedFeatureSelector: UserActivatedFeaturesSelector,
         blockheightRepository: BlockchainHeightRepository
    ) {
        self.updateUserPreferences = updateUserPreferences
        self.userPreferencesSelector = userPreferencesSelector
        self.userActivatedFeatureSelector = userActivatedFeatureSelector
        self.blockheightRepository = blockheightRepository
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        let taprootFeature = Libwallet.userActivatedFeatureTaproot()!
        switch userActivatedFeatureSelector.get(for: taprootFeature) {

        case .active:
            subscribeToPreference()

        case .scheduledActivation(let blocksLeft),
             .preactivated(let blocksLeft):
            delegate?.update(hoursToActivation: BlockHelper.hoursFor(blocksLeft))

        case .canActivate,
             .canPreactivate,
             .off:
            Logger.fatal("Somehow got into the onchain settings screen without activating taproot")
        }
    }

    private func subscribeToPreference() {

        let combined = Observable.combineLatest(
            userPreferencesSelector.watch(),
            updateUserPreferences.getState()
        )

        subscribeTo(combined, onNext: self.handleUpdateState)
    }

    func toggle() {
        updateUserPreferences.run { prefs in
            if prefs.defaultAddressType == .segwit {
                return prefs.copy(defaultAddressType: .taproot)
            } else {
                return prefs.copy(defaultAddressType: .segwit)
            }
        }
    }

    func handleUpdateState(_ state: (UserPreferences, ActionState<Void>)) {

        let (prefs, action) = state

        switch action.type {
        case .EMPTY, .ERROR:
            delegate?.setLoading(false)
            delegate?.update(enabled: prefs.defaultAddressType == .taproot)

        case .LOADING:
            delegate?.setLoading(true)

        case .VALUE:
            break
        }
    }
}
