//
//  DeviceCheckDataProvider.swift
//  falcon
//
//  Created by Ramiro Repetto on 13/10/2025.
//  Copyright © 2025 muun. All rights reserved.
//

public class DeviceCheckDataProvider {

    private let keychainRepository: KeychainRepository

    init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    func getDeviceCheckToken() -> String {
        let deviceTokenKey = KeychainRepository.storedKeys.deviceCheckToken.rawValue
        // swiftlint:disable force_error_handling
        let deviceToken = try? keychainRepository.get(deviceTokenKey)
        return deviceToken ?? DeviceTokenErrorValues.failToRetrieve.rawValue
    }

    func getFallbackDeviceToken() -> String {
        let deviceTokenKey = KeychainRepository.storedKeys.fallbackDeviceToken.rawValue
        // swiftlint:disable force_error_handling
        let deviceToken = try? keychainRepository.get(deviceTokenKey)
        return deviceToken ?? DeviceTokenErrorValues.failToRetrieve.rawValue
    }
}
