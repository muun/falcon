//
//  FeatureFlagLocalOverridesRepository.swift
//  falcon
//
//  Created by Daniel Mankowski on 04/11/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

/// FeatureFlagLocalOverridesRepository store features flags locally disabled by user
final class FeatureFlagsOverridesRepository {
    private let libwalletKeyPrefix = "featureFlagOverrides:"

    private let walletService: WalletService
    // Map libwallet storage keys -> FeatureFlags
    private var libwalletKeyToFeatureFlag: [String: FeatureFlags] {
        FeatureFlags.allCases.reduce(into: [:]) { result, flag in
            if flag.overrideMetadata.isOverridable, let key = storageKey(for: flag) {
                result[key] = flag
            }
        }
    }

    init(walletService: WalletService) {
        self.walletService = walletService
    }

    public func setFlag(_ flag: FeatureFlags, isDisabled: Bool) {
        guard let libwalletKey = storageKey(for: flag) else {
            return
        }
        walletService.saveBool(
            key: libwalletKey,
            value: isDisabled
        )
    }

    public func fetchDisabledFlags() -> Set<FeatureFlags> {
        let overrideFlags = walletService.getBoolByPrefix(
            prefix: libwalletKeyPrefix
        )

        return Set(overrideFlags.compactMap { (key, disabled) in
            guard disabled else { return nil }
            return libwalletKeyToFeatureFlag[key]
        })
    }

    private func storageKey(for flag: FeatureFlags) -> String? {
        if case let .overridable(_, libwalletKeySuffix) = flag.overrideMetadata {
            return libwalletKeyPrefix + libwalletKeySuffix
        }
        // It should not be executed, all the flags are overridable at this point.
        return nil
    }
}
