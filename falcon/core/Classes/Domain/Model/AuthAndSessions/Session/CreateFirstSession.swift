//
//  CreateFirstSession.swift
//  core
//
//  Created by Manu Herrera on 24/04/2020.
//

import Foundation

struct CreateFirstSession {

    let client: Client
    let gcmToken: String
    let primaryCurrency: String
    let basePublicKey: WalletPublicKey

}

public struct CreateFirstSessionOk {

    let user: User
    let cosigningPublicKey: WalletPublicKey
    let swapServerPublicKey: WalletPublicKey

}

import core

struct Client {

    let type: String = "FALCON"
    let buildType: String
    let version: Int
    let versionName: String
    let deviceModel: String
    let timezoneOffsetInSeconds: Int64
    let language: String
    let deviceCheckToken: String

    static func buildCurrent() -> Client {
        return Client(
            buildType: Environment.current.buildType,
            version: Int(core.Constant.buildVersion)!,
            versionName: core.Constant.buildVersionName,
            deviceModel: DeviceUtils.deviceInfo().model,
            timezoneOffsetInSeconds: Int64(TimeZone.current.secondsFromGMT()),
            language: Locale.current.identifier,
            deviceCheckToken: getDeviceCheckToken()
        )
    }
    
    static func getDeviceCheckToken() -> String {
        let deviceTokenKey = KeychainRepository.storedKeys.deviceCheckToken.rawValue
        let keychainRepository = KeychainRepository()
        let deviceToken = try? keychainRepository.get(deviceTokenKey)
        return deviceToken ?? DeviceTokenErrorValues.failToRetrieve.rawValue
    }
}
