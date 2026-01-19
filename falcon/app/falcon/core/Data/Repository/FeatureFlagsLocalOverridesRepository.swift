//
//  FeatureFlagLocalOverridesRepository.swift
//  falcon
//
//  Created by Daniel Mankowski on 04/11/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

/// FeatureFlagLocalOverridesRepository store features flags locally disabled by user
final class FeatureFlagsLocalOverridesRepository {
    private let walletService: WalletService

    init(walletService: WalletService) {
        self.walletService = walletService
    }

    public func setOverrideNfcCardV2(isDisabled: Bool) {
        walletService.saveBool(
            key: Persistence.featureFlagOverridesNfcCardV2.rawValue,
            value: isDisabled
        )
    }

    public func isFlagDisabled(_ flag: FeatureFlags) -> Bool {
        switch flag {
        case .nfcCardV2:
            return walletService.getBool(
                key: Persistence.featureFlagOverridesNfcCardV2.rawValue,
                defaultValue: false
            )
        default:
            return false
        }
    }
}
