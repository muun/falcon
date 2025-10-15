//
//  CreateFirstSession.swift
//
//  Created by Manu Herrera on 24/04/2020.
//

import Foundation

struct CreateFirstSession {

    let client: Client
    // GcmToken is not retrieved until notification permission approval.
    let gcmToken: String?
    let primaryCurrency: String
    let basePublicKey: WalletPublicKey

}

public struct CreateFirstSessionOk {

    let user: User
    let cosigningPublicKey: WalletPublicKey
    let swapServerPublicKey: WalletPublicKey

}

struct Client {

    let type: String = "FALCON"
    let buildType: String
    let version: Int
    let versionName: String
    let deviceModel: String
    let timezoneOffsetInSeconds: Int64
    let language: String
    let deviceCheckToken: String
    let fallbackDeviceToken: String
    let systemUptime: TimeInterval
    let iCloudRecordId: String?
    let appDisplayName: String
    let appId: String
    let appName: String
    let appPrimaryIconHash: String
    let isSoftDevice: Bool
    let softDeviceName: String?
    let hasGyro: Bool
    let installSource: Int

}
