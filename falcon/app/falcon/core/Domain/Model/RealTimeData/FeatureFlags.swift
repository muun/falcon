//
//  FeatureFlags+Extension.swift
//  falcon
//
//  Created by Daniel Mankowski on 22/12/2025.
//  Copyright © 2025 muun. All rights reserved.
//

public enum FeatureFlags: String, RawRepresentable, CaseIterable {
    case Taproot = "TAPROOT"
    case TaprootPreactivation = "TAPROOT_PREACTIVATION"
    case highFeesHomeBanner = "HIGH_FEES_HOME_BANNER"
    case osVersionDeprecatedFlow = "OS_VERSION_DEPRECATED_FLOW"
    case highFeesReceiveFlow = "HIGH_FEES_RECEIVE_FLOW"
    case collectDeviceCheckReachability = "COLLECT_DEVICE_CHECK_REACHABILITY"
    case effectiveFeesCalculation = "EFFECTIVE_FEES_CALCULATION"
    case nfcCard = "NFC_CARD"
    case nfcCardV2 = "NFC_CARD_V2"
    case securityCardsMarketplace = "SECURITY_CARDS_MARKETPLACE"
}

enum FeatureFlagOverrideInfo {
    // IMPORTANT:
    // If you mark a flag as overridable, you MUST ensure that a matching
    // override key exists in Libwallet Storage and matches exactly (case-sensitive).
    // See libwallet/storage/schema.go.
    // Otherwise, the Disable Feature Flags screen will crash.
    case overridable(humanReadableDescription: String, libwalletKeySuffix: String)
    case notOverridable

    var isOverridable: Bool {
        if case .overridable = self {
            return true
        }
        return false
    }
}

// MARK: - Required metadata for override flag (compiler-enforced)

// Use this mapping to define whether a feature flag can be overridden locally.
//
// - Return `.notOverridable` for flags that must not be overridden locally.
// - Return `.overridable` for flags that support local overrides.
//   When using `.overridable`, you MUST provide:
//   - A human-readable description (shown in the Disable Feature Flags screen)
//   - A libwallet key name that matches exactly the storage key suffix used by libwallet
//     (see libwallet/storage/schema.go). The `featureFlagOverrides:` prefix
//     is automatically added by the storage repository.
extension FeatureFlags {
    var overrideMetadata: FeatureFlagOverrideInfo {
        switch self {
        case .Taproot, .TaprootPreactivation, .highFeesHomeBanner, .osVersionDeprecatedFlow,
                .highFeesReceiveFlow, .collectDeviceCheckReachability, .effectiveFeesCalculation,
                .nfcCard, .securityCardsMarketplace:
            return .notOverridable
        case .nfcCardV2:
            return .overridable(
                humanReadableDescription: "Enables NFC Security Card V2 support",
                libwalletKeySuffix: "nfcCardV2"
            )
        }
    }
}
