//
//  BiometricsStatusProvider.swift
//  falcon
//
//  Created by Federico Jordán on 29/12/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import LocalAuthentication

/// Represents the current biometric capability and configuration of the device.
/// It differentiates both the biometric type (Face ID / Touch ID)
/// and whether it is currently enabled or disabled by the user.
enum BiometricsStatus {
    case enabledTouchID
    case enabledFaceID
    case disabledTouchID
    case disabledFaceID
}

final class BiometricsStatusProvider {
    /// Raw biometric status for analytics. Used in *s_settings* event parameters in `SettingsViewController`
    var analyticsBiometricsStatus: String = "unknown"

    /// Raw biometric status reason for analytics. Used in *s_settings* event parameters in `SettingsViewController`
    var analyticsBiometricsStatusReason: String?

    /// Determines the current biometric status of the device.
    ///
    /// This method first checks whether biometric authentication
    /// can be evaluated using `.deviceOwnerAuthenticationWithBiometrics`.
    ///
    /// If this policy can be evaluated, it means:
    /// - The device supports biometrics
    /// - Biometrics are enabled by the user
    /// - We can safely rely on `biometryType` to know whether it's Face ID or Touch ID
    ///
    /// If the evaluation fails, we fallback to a different policy
    /// to still retrieve the biometric type (even if disabled).
    func biometricsStatus() -> BiometricsStatus {
        let context = LAContext()
        var error: NSError?

        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        if canEvaluate {
            switch context.biometryType {
            case .touchID:
                return .enabledTouchID
            case .faceID:
                return .enabledFaceID
            default:
                return biometricsStatusWhenDisabled()
            }
        } else {
            return biometricsStatusWhenDisabled()
        }
    }
    
    func requestAuthentication(completion: @escaping () -> Void, failure: @escaping () -> Void) {

        let myContext = LAContext()
        var text = ""
        var authError: NSError?

        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            analyticsBiometricsStatus = "enabled"
            switch myContext.biometryType {
            case .faceID:
                text = L10n.PinViewController.s1
            case .touchID:
                text = L10n.PinViewController.s2
            case .none:
                text = L10n.PinViewController.s3
            @unknown default:
                fatalError("Implement the new biometric type")
            }
            
            AnalyticsHelper.logScreen("biometrics_auth", parameters: nil)
            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: text) { success, error in
                DispatchQueue.main.async {
                    if success {
                        AnalyticsHelper.logEvent("biometrics_auth_success")
                        completion()
                    } else {
                        let nsError = error as NSError?
                        AnalyticsHelper.logEvent(
                            "biometrics_auth_error",
                            parameters: [
                                "code": nsError?.code ?? -1,
                                "desc": nsError?.localizedDescription ?? "unknown error"
                            ]
                        )
                        failure()
                    }
                }
            }
        } else {
            // TODO: Show a "Face id not set up" pop up
            analyticsBiometricsStatus = "disabled"
            analyticsBiometricsStatusReason = authError?.localizedDescription ?? "unknown error"
            
            failure()
        }
    }

    /// Determines the biometric type when biometrics are disabled.
    ///
    /// Important detail:
    /// `.deviceOwnerAuthentication` is intentionally used here instead of
    /// `.deviceOwnerAuthenticationWithBiometrics`.
    ///
    /// This policy allows retrieving `biometryType` even when:
    /// - Biometrics are disabled by the user
    /// - No biometrics are enrolled
    ///
    /// This enables us to differentiate between:
    /// - Disabled Face ID
    /// - Disabled Touch ID
    ///
    /// Without this fallback, we would lose information about the biometric type.
    private func biometricsStatusWhenDisabled() -> BiometricsStatus {
        let context = LAContext()
        var error: NSError?

        _ = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)

        switch context.biometryType {
        case .faceID:
            return .disabledFaceID
        case .touchID:
            return .disabledTouchID
        default:
            fatalError("Not expected to handle this biometric type.")
        }
    }
}
