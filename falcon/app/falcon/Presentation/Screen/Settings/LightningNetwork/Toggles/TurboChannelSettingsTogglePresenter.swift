//
//  TurboChannelSettingsTogglePresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 04/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation


import RxSwift

class TurboChannelSettingsTogglePresenter<Delegate: SettingsTogglePresenterDelegate>: BasePresenter<Delegate> {
    private let userPreferencesResolver: SettingToggleUserPreferenciesResolver

    init(delegate: Delegate,
         userPreferencesResolver: SettingToggleUserPreferenciesResolver) {
        self.userPreferencesResolver = userPreferencesResolver
        super.init(delegate: delegate)
    }

    private func subscribeTo(userPreferencesResolver: SettingToggleUserPreferenciesResolver) {
        let observable = userPreferencesResolver.setUpPreferencesListeners()

        subscribeTo(observable, onNext: {[weak self] state in
            let (prefs, action) = state

            switch action.type {
            case .EMPTY, .ERROR:
                self?.delegate.enabled = !prefs.receiveStrictMode
                self?.delegate.loading = false
            case .LOADING:
                self?.delegate.loading = true
            case .VALUE:
                break
            }
        })
    }

    @objc
    static func didTapLearnMore() {
        UIApplication.shared.open(
            URL(string: L10n.LightningNetworkSettings.blogPost)!, options: [:]
        )
    }

    static func createView() -> SettingsToggleView {
        let updateUserPreferences: UpdateUserPreferencesAction = AppDelegate.resolve()
        let userPreferencesSelector: UserPreferencesSelector = AppDelegate.resolve()
        let userPrefrences = SettingToggleUserPreferenciesResolver(updateUserPreferences: updateUserPreferences,
                                                                   userPreferencesSelector: userPreferencesSelector)

        let learnMoreLabel = createLearnMoreLabel()
        let view = SettingsToggleView(title: L10n.LightningNetworkSettings.turboChannels,
                                      subtitle: learnMoreLabel,
                                      toggleIdentifierForTesting: .turboChannels)
        // swiftlint:disable force_cast
        let presenter = TurboChannelSettingsTogglePresenter(delegate: view as! Delegate,
                                                            userPreferencesResolver: userPrefrences)
        view.presenter = presenter
        return view
    }

    private func toggleConfig() {
        userPreferencesResolver.updateSetting { prefs in
            prefs.copy(receiveStrictMode: !prefs.receiveStrictMode)
        }
    }

    private static func createLearnMoreLabel() -> UILabel {
        let learnMoreLabel = UILabel()
        learnMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        learnMoreLabel.attributedText = L10n.LightningNetworkSettings.learnMore
            .set(font: Constant.Fonts.system(size: .notice))
            .set(underline: L10n.LightningNetworkSettings.learnMoreUnderline, color: Asset.Colors.muunBlue.color)
        learnMoreLabel.setContentHuggingPriority(.required, for: .vertical)
        learnMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        learnMoreLabel.isUserInteractionEnabled = true
        learnMoreLabel.numberOfLines = 0
        learnMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLearnMore))
        )

        return learnMoreLabel
    }

    override func setUp() {
        super.setUp()
        subscribeTo(userPreferencesResolver: userPreferencesResolver)
    }
}

extension TurboChannelSettingsTogglePresenter: SettingsTogglePresenter {
    func onToggleTapped() {
        if delegate.enabled {
            showDisableTurboChannelsAlert()
        } else {
            toggleConfig()
        }
    }

    private func showDisableTurboChannelsAlert() {
        let disableText = L10n.LightningNetworkSettings.disable
        let alertData = SettingsToggleAlertData(title: L10n.LightningNetworkSettings.confirmTitle,
                                                message: L10n.LightningNetworkSettings.confirmDescription,
                                                cancelButtonTitle: L10n.SettingsViewController.cancel,
                                                cancelButtonBlock: { [weak self] in
            self?.delegate.enabled = true
        },
                                                destructiveButtonTitle: disableText,
                                                destructiveButtonBlock: { [weak self] in
            self?.toggleConfig()
        })
        delegate.showAlert(data: alertData)
    }
}
