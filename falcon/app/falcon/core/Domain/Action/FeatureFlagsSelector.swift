//
//  FeatureFlagsSelector.swift
//
//  Created by Lucas Serruya on 09/05/2023.
//

import Foundation
import RxSwift

public class FeatureFlagsSelector: AsyncAction<[FeatureFlags]> {

    private let featureFlagsRepository: FeatureFlagsRepository
    private let featureFlagLocalOverridesRepository: FeatureFlagsLocalOverridesRepository

    init(
        featureFlagsRepository: FeatureFlagsRepository,
        featureFlagLocalOverridesRepository: FeatureFlagsLocalOverridesRepository
    ) {
        self.featureFlagsRepository = featureFlagsRepository
        self.featureFlagLocalOverridesRepository = featureFlagLocalOverridesRepository

        super.init(name: "FeatureFlagsSelector")
    }

    public func run() -> Observable<[FeatureFlags]> {
        return featureFlagsRepository.watch()
    }

    public func fetch() -> [FeatureFlags] {
        return featureFlagsRepository.fetch()
    }

    // In dogfood builds, users can locally disable NFC_CARD feature flag
    // for testing purposes. In production, only backend value is considered.
    public func isSecurityCardFlagEnabled() -> Bool {
        let enabledInBackend = featureFlagsRepository.fetch().contains(.nfcCardV2)
        #if DOGFOOD || DEBUG
        let disabledLocally = featureFlagLocalOverridesRepository.isFlagDisabled(.nfcCardV2)
        return enabledInBackend && !disabledLocally
        #else
        return enabledInBackend
        #endif
    }
}
