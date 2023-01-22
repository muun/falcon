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
                                                  batteryLevel: getBatterylevel(),
                                                  batteryState: getBatteryState())
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

    private static func getBatterylevel() -> Float {
        return UIDevice.current.batteryLevel
    }

    private static func getBatteryState() -> String {
        switch (UIDevice.current.batteryState) {
        case .unknown: return "UNKNOWN"
        case .charging: return "CHARGING"
        case .full: return "FULL"
        case .unplugged: return "UNPLUGGED"
        }
    }
}

struct BackgroundExcecutionMetrics: Encodable {
    let epochInMilliseconds: Int64
    let batteryLevel: Float
    let batteryState: String
}
