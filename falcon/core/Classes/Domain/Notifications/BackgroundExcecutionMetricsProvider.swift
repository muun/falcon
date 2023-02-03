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
        let metrics = BackgroundExcecutionMetrics(epochInMilliseconds: createEpoch(),
                                                  batteryLevel: HardwareCapabilitiesProvider.getBatterylevel(),
                                                  batteryState: HardwareCapabilitiesProvider.getBatteryState(),
                                                  freeRAMStorage: HardwareCapabilitiesProvider.getFreeRam(),
                                                  freeTotalStorage: HardwareCapabilitiesProvider.getFreeStorage(),
                                                  simState: ConectivityCapabilitiesProvider.shared.getSimState().rawValue,
                                                  hasInternetConnectionProvidedByCarrier: ConectivityCapabilitiesProvider.shared.hasInternetConnectionProvidedByCarrier(),
                                                  currentlyOverWifi: ConectivityCapabilitiesProvider.shared.isOverWifi
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
    let freeRAMStorage: Int64
    let freeTotalStorage: Int64
    let simState: String
    let hasInternetConnectionProvidedByCarrier: Bool?
    let currentlyOverWifi: Bool?
}
