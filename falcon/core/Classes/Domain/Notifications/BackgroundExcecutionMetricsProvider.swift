//
//  BackgroundExcecutionMetricsProvider.swift
//  core-all
//
//  Created by Lucas Serruya on 17/01/2023.
//

import Foundation

struct BackgroundExcecutionMetricsProvider {
    static func run() -> String? {
        /// isBatteryMonitoringEnabled is required in order to get battery metrics.
        UIDevice.current.isBatteryMonitoringEnabled = true

        let hardwareCapabilities = HardwareCapabilitiesProvider.shared
        let hasInternetConnectionProvidedByCarrier =
            ConectivityCapabilitiesProvider.shared.hasInternetConnectionProvidedByCarrier()

        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString =
            "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        let metrics = BackgroundExcecutionMetrics(
            epochInMilliseconds: createEpoch(),
            batteryLevel: hardwareCapabilities.getBatterylevel(),
            batteryState: hardwareCapabilities.getBatteryState(),
            freeRamStorage: hardwareCapabilities.getFreeRam(),
            freeInternalStorage: hardwareCapabilities.getFreeStorage(),
            simState: ConectivityCapabilitiesProvider.shared.getSimState().rawValue,
            hasInternetConnectionProvidedByCarrier: hasInternetConnectionProvidedByCarrier,
            currentlyOverWifi: ConectivityCapabilitiesProvider.shared.isOverWifi,
            totalInternalStorage: hardwareCapabilities.getTotalStorage(),
            totalRamStorage: hardwareCapabilities.getTotalRam(),
            osVersion: osVersionString
        )
        let encoder = JSONEncoder()
        guard let metricsAsData = try? encoder.encode(metrics) else {
            return nil
        }

        return String(decoding: metricsAsData, as: UTF8.self)
    }

    private static func createEpoch() -> Int64 {
        /// timeIntervalSince1970 provides miliseconds on decimal part so we can get epoch time as int in miliseconds.
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

struct BackgroundExcecutionMetrics: Encodable {
    let epochInMilliseconds: Int64
    let batteryLevel: Float
    let batteryState: String
    let freeRamStorage: Int64
    let freeInternalStorage: Int64
    let simState: String
    let hasInternetConnectionProvidedByCarrier: Bool?
    let currentlyOverWifi: Bool?
    let totalInternalStorage: Int64
    let totalRamStorage: UInt64
    let osVersion: String
}
