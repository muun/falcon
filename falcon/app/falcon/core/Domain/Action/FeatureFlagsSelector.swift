//
//  FeatureFlagsSelector.swift
//
//  Created by Lucas Serruya on 09/05/2023.
//

import Foundation
import Libwallet
import RxSwift

/// Abstracts dogfood functionality that allows users to manually disable some feature flags.
/// If a FeatureFlag is overridden, it is effectively disabled.
public class FeatureFlagsSelector: AsyncAction<[FeatureFlags]> {

    private let featureFlagsRepository: FeatureFlagsRepository
    private let featureFlagLocalOverridesRepository: FeatureFlagsOverridesRepository

    init(
        featureFlagsRepository: FeatureFlagsRepository,
        featureFlagLocalOverridesRepository: FeatureFlagsOverridesRepository
    ) {
        self.featureFlagsRepository = featureFlagsRepository
        self.featureFlagLocalOverridesRepository = featureFlagLocalOverridesRepository

        super.init(name: "FeatureFlagsSelector")
    }

    public func run() -> Observable<[FeatureFlags]> {
        #if DEBUG || DOGFOOD
        return featureFlagsRepository.watch().map { flags in
            return self.applyLocalOverrides(flags)
        }
        #else
        return featureFlagsRepository.watch()
        #endif
    }

    public func fetch() -> [FeatureFlags] {
        let flags = featureFlagsRepository.fetch()
        #if DEBUG || DOGFOOD
        return applyLocalOverrides(flags)
        #else
        return flags
        #endif
    }

    public func isFlagEnabled(_ flag: FeatureFlags) -> Bool {
        fetch().contains(flag)
    }

    /// Avoid using unless you REALLY know what you're doing. You probably just want to use the
    /// fetch with overrides.
    public func fetchWithoutOverrides() -> [FeatureFlags] {
        return featureFlagsRepository.fetch()
    }

    private func applyLocalOverrides(_ flags: [FeatureFlags]) -> [FeatureFlags] {
        let disabledFlags = featureFlagLocalOverridesRepository.fetchDisabledFlags()
        return flags.filter { !disabledFlags.contains($0) }
    }
}

// Not for application use. This is a bridge to provide feature flag information to libwallet
// until we implement a more generic libwallet-side storage mechanism.
// Even though the method is named `isBackendFlagEnabled`, it intentionally
// takes local overrides into account.
extension FeatureFlagsSelector : App_provided_dataBackendActivatedFeatureStatusProviderProtocol {
    public func isBackendFlagEnabled(_ flag: String?) -> Bool {
        guard let flagName = flag, let flag = FeatureFlags(rawValue: flagName) else {
            Logger.log(.err, "Tried to read null or invalid feature flag from libwallet.")
            return false
        }
        return isFlagEnabled(flag)
    }
}
