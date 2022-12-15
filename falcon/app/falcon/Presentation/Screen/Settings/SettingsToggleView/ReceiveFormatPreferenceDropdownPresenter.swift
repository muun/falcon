//
//  SettingsDropdownPresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 22/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

protocol SettingsDropdownPresenter: AnyObject {
    func didChange(value: ReceiveFormatPreference)
    func setUp()
    func tearDown()
    func didTapDropdown()
}

protocol SettingsDropdownPresenterDelegate: BasePresenterDelegate {
    var state: ReceiveFormatPreferenceViewModel { get set }
    var loading: Bool { get set }
    func presentActionSheet(actionSheetDelegate: MUActionSheetViewDelegate,
                            selectedOption: any MUActionSheetOption)
}

class ReceiveFormatPreferenceDropdownPresenter<Delegate: SettingsDropdownPresenterDelegate>: BasePresenter<Delegate> {
    private let userPreferencesResolver: SettingToggleUserPreferenciesResolver
    private var currentState: ReceiveFormatPreference?
    init(delegate: Delegate,
         userPreferencesResolver: SettingToggleUserPreferenciesResolver) {
        self.userPreferencesResolver = userPreferencesResolver
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(userPreferenciesResolver: userPreferencesResolver)
    }

    private func subscribeTo(userPreferenciesResolver: SettingToggleUserPreferenciesResolver) {
        let observable = userPreferenciesResolver.setUpPreferencesListeners()
        subscribeTo(observable, onNext: { [weak self] state in
            let (prefs, action) = state

            switch action.type {
            case .EMPTY, .ERROR:
                self?.currentState = prefs.receiveFormatPreference
                self?.delegate.state = ReceiveFormatPreferenceViewModel.from(model: prefs.receiveFormatPreference)
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
            URL(string: L10n.ReceiveFormatSettingDropdownView.learnMoreLink)!, options: [:]
        )
    }

    static func createView() -> ReceiveFormatSettingDropdownView {
        let updateUserPreferences: UpdateUserPreferencesAction = AppDelegate.resolve()
        let userPreferencesSelector: UserPreferencesSelector = AppDelegate.resolve()

        let preferences = SettingToggleUserPreferenciesResolver(updateUserPreferences: updateUserPreferences,
                                                                 userPreferencesSelector: userPreferencesSelector)
        let subtitleLabel = createSubtitleLabel()
        let view = ReceiveFormatSettingDropdownView(title: L10n.ReceiveFormatSettingDropdownView.title,
                                        subtitle: subtitleLabel)
        // swiftlint:disable force_cast
        let presenter = ReceiveFormatPreferenceDropdownPresenter(delegate: view as! Delegate,
                                                                 userPreferencesResolver: preferences)

        view.presenter = presenter
        return view
    }

    private static func createSubtitleLabel() -> UILabel {
        let learnMoreLabel = UILabel()
        learnMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        learnMoreLabel.attributedText = L10n.ReceiveFormatSettingDropdownView.description
            .set(font: Constant.Fonts.system(size: .notice))
            .set(underline: L10n.ReceiveFormatSettingDropdownView.learnMoreUnderline,
                 color: Asset.Colors.muunBlue.color)
        learnMoreLabel.setContentHuggingPriority(.required, for: .vertical)
        learnMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        learnMoreLabel.isUserInteractionEnabled = true
        learnMoreLabel.numberOfLines = 0
        learnMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLearnMore))
        )

        return learnMoreLabel
    }
}

extension ReceiveFormatPreferenceDropdownPresenter: SettingsDropdownPresenter {
    func didChange(value: ReceiveFormatPreference) {
        userPreferencesResolver.updateSetting { prefs in
            prefs.copy(receiveFormatPreference: prefs.receiveFormatPreference)
        }
    }

    func didTapDropdown() {
        guard let currentState = currentState else {
            return // User has tapped the setting before it was loaded
        }
        delegate.presentActionSheet(actionSheetDelegate: self,
                                    selectedOption: ReceiveFormatPreferenceViewModel.from(model: currentState))
    }
}

extension ReceiveFormatPreferenceDropdownPresenter: MUActionSheetViewDelegate {
    func didSelect(option: any MUActionSheetOption) {
        let selectedReceiveOption = option as! ReceiveFormatPreferenceViewModel
        let currentModelSelection = ReceiveFormatPreference(rawValue: selectedReceiveOption.rawValue)
        userPreferencesResolver.updateSetting { prefs in
            prefs.copy(receiveFormatPreference: currentModelSelection)
        }
    }
}
