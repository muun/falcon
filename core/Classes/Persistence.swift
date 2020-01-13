//
//  Persistence.swift
//  falcon
//
//  Created by Manu Herrera on 05/10/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public enum Persistence: String, CaseIterable {

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

    case baseKeyDerivationPath
    case basePublicKey
    case basePrivateKey

    case muunPublicKey
    case muunPublicKeyPath

    case lastOwnAddressCopied

    case isDarkMode

    case isBalanceHidden
    case displayFiatCurrencyAsMain
    case displayBTCasSAT

    case hasRecoveryCode
    case rcSetupInProcess

    case syncStatus

    case currentEnvironment

    case blockchainHeight
}
