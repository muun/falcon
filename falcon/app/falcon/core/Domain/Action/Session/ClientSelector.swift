//
//  ClientSelector.swift
//
//  Created by Juan Pablo Civile on 12/07/2023.
//

import Foundation

class ClientSelector {

    private let iCloudCapabilitiesProvider: ICloudCapabilitiesProvider
    private let keychainRepository: KeychainRepository

    init(iCloudCapabilitiesProvider: ICloudCapabilitiesProvider,
         keychainRepository: KeychainRepository
    ) {
        self.iCloudCapabilitiesProvider = iCloudCapabilitiesProvider
        self.keychainRepository = keychainRepository
    }

    func run() -> Client {
        return Client(
            buildType: Environment.current.buildType,
            version: Int(Constant.buildVersion)!,
            versionName: Constant.buildVersionName,
            deviceModel: DeviceUtils.deviceInfo().model,
            timezoneOffsetInSeconds: Int64(TimeZone.current.secondsFromGMT()),
            language: Locale.current.identifier,
            deviceCheckToken: getDeviceCheckToken(),
            fallbackDeviceToken: getFallbackDeviceToken(),
            systemUptime: ProcessInfo.processInfo.systemUptime,
            iCloudRecordId: iCloudCapabilitiesProvider.fetchRecordId()
        )
    }

    private func getDeviceCheckToken() -> String {
        let deviceTokenKey = KeychainRepository.storedKeys.deviceCheckToken.rawValue
        // swiftlint:disable force_error_handling
        let deviceToken = try? keychainRepository.get(deviceTokenKey)
        return deviceToken ?? DeviceTokenErrorValues.failToRetrieve.rawValue
    }

    private func getFallbackDeviceToken() -> String {
        let deviceTokenKey = KeychainRepository.storedKeys.fallbackDeviceToken.rawValue
        // swiftlint:disable force_error_handling
        let deviceToken = try? keychainRepository.get(deviceTokenKey)
        return deviceToken ?? DeviceTokenErrorValues.failToRetrieve.rawValue
    }
}
