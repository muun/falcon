//
//  DisableFeatureFlagsPresenter.swift
//  falcon
//
//  Created by Daniel Mankowski on 05/11/2025.
//  Copyright © 2025 muun. All rights reserved.
//
import Foundation

protocol DisableFeatureFlagsPresenterDelegate: BasePresenterDelegate {}

final class DisableFeatureFlagsPresenter<Delegate: DisableFeatureFlagsPresenterDelegate>:
    BasePresenter<Delegate> {

    var isNfcCardEnabled: Bool = true

    private let featureFlagLocalOverridesRepository: FeatureFlagsLocalOverridesRepository

    init(
        delegate: Delegate,
        featureFlagLocalOverridesRepository: FeatureFlagsLocalOverridesRepository
    ) {
        self.featureFlagLocalOverridesRepository = featureFlagLocalOverridesRepository

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        isNfcCardEnabled = !featureFlagLocalOverridesRepository.isFlagDisabled(.nfcCardV2)
    }

    func setNfcFlagEnabled(_ isEnabled: Bool) {
        featureFlagLocalOverridesRepository.setOverrideNfcCardV2(isDisabled: !isEnabled)
        let parameters: [String: Any] = [
            "name": "nfc_card_v2",
            "is_enabled": isEnabled
        ]
        AnalyticsHelper.logEvent("feature_flag_override", parameters: parameters)
    }
}
