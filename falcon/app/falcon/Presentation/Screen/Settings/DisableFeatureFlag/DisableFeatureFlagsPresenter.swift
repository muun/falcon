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

    private let featureFlagsSelector: FeatureFlagsSelector
    private let featureFlagLocalOverridesRepository: FeatureFlagsOverridesRepository

    private lazy var overridableFlags: [FeatureFlags] = {
        featureFlagsSelector.fetchWithoutOverrides().filter { $0.overrideMetadata.isOverridable }
    }()

    private lazy var disabledFlags: Set<FeatureFlags> = {
        featureFlagLocalOverridesRepository.fetchDisabledFlags()
    }()

    init(
        delegate: Delegate,
        featureFlagsSelector: FeatureFlagsSelector,
        featureFlagLocalOverridesRepository: FeatureFlagsOverridesRepository
    ) {
        self.featureFlagLocalOverridesRepository = featureFlagLocalOverridesRepository
        self.featureFlagsSelector = featureFlagsSelector

        super.init(delegate: delegate)
    }

    func setFlagDisabled(_ flag: FeatureFlags, isDisabled: Bool) {
        featureFlagLocalOverridesRepository.setFlag(flag, isDisabled: isDisabled)

        let parameters: [String: Any] = [
            "name": flag.rawValue.lowercased(),
            "is_enabled": !isDisabled
        ]
        AnalyticsHelper.logEvent("feature_flag_override", parameters: parameters)
    }

    func numberOfRows() -> Int {
        return overridableFlags.count
    }

    func flag(for indexPath: IndexPath) -> FeatureFlags {
        return overridableFlags[indexPath.row]
    }

    func isOn(flag: FeatureFlags) -> Bool {
        return !disabledFlags.contains(flag)
    }
}
