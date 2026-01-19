//
//  ClientSelector.swift
//
//  Created by Juan Pablo Civile on 12/07/2023.
//

import Foundation

class ClientSelector {

    private let metricsProvider: MetricsProvider

    init(metricsProvider: MetricsProvider) {
        self.metricsProvider = metricsProvider
    }

    func run() -> Client {
        return Client(
            buildType: Environment.current.buildType,
            version: Int(Constant.buildVersion)!,
            versionName: Constant.buildVersionName,
            deviceModel: DeviceUtils.deviceInfo().model,
            timezoneOffsetInSeconds: Int64(metricsProvider.timeZoneOffsetInSeconds),
            language: metricsProvider.language,
            deviceCheckToken: metricsProvider.deviceCheckToken,
            fallbackDeviceToken: metricsProvider.fallbackDeviceToken,
            appDisplayName: metricsProvider.appDisplayName,
            appId: metricsProvider.appId,
            appName: metricsProvider.appName,
            appPrimaryIconHash: metricsProvider.appPrimaryIconHash,
            isSoftDevice: metricsProvider.isSoftDevice,
            softDeviceName: metricsProvider.softDeviceName,
            hasGyro: metricsProvider.hasGyro,
            installSource: metricsProvider.installSource
        )
    }
}
