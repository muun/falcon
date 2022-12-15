//
//  Persistence.swift
//  falcon
//
//  Created by Manu Herrera on 05/10/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public enum Persistence: String, CaseIterable {

    case apiMigrationsVersion

    case email
    case gcmToken
    case isBiometricIdSet

    case appInForeground
    case lastNotificationId

    case sessionStatus = "session_status"

    case feeWindow
    case exchangeRateWindow

    case nextTransactionSize

    case user

    case maxWatchingIndex
    case maxUsedIndex

    // baseKeyDerivationPath is deprecated: Use baseKeyDerivationPath in SecureStorage
    case baseKeyDerivationPath

    case basePublicKey
    case basePrivateKey

    case muunPublicKey
    case muunPublicKeyPath

    case swapServerPublicKey
    case swapServerPublicKeyPath

    case muunKeyFingerprint
    case userKeyFingerprint

    case lastOwnAddressCopied

    case isBalanceHidden // Bool
    case displayBTCasSAT // Bool

    case hasRecoveryCode // Bool

    case syncStatus

    case currentEnvironment

    case blockchainHeight

    case welcomeMessageSeen

    case passwordChangeVerification

    case rcSignInAuthorization

    case isEmailSkipped

    case didSkipPushNotificationPermission

    case forwardingPolicies

    case minFeeRate
    
    case hasResolvedARcChallenge

    case emergencyKitVerificationCodes // [String]

    case userPreferences

    case featureFlags

    case preactivedTaproot
}
