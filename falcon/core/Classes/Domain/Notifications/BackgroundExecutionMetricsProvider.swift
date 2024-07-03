//
//  BackgroundExcecutionMetricsProvider.swift
//  core-all
//
//  Created by Lucas Serruya on 17/01/2023.
//

import Foundation

class BackgroundExecutionMetricsProvider {
    var reachabilityService: ReachabilityService?

    func run() -> String? {
        /// isBatteryMonitoringEnabled is required in order to get battery metrics.
        UIDevice.current.isBatteryMonitoringEnabled = true

        let conectivityCapabilities = ConectivityCapabilitiesProvider.shared
        let hardwareCapabilities = HardwareCapabilitiesProvider.shared
        let hasInternetConnectionProvidedByCarrier =
            conectivityCapabilities.hasInternetConnectionProvidedByCarrier()

        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString =
            "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        var availableNetworksDTO: AvailableNetworksDTO?
        conectivityCapabilities.availableNetworks.map {
            availableNetworksDTO = AvailableNetworksDTO.from(model: $0)
        }

        let reachabilityStatus = reachabilityService?.getReachabilityStatus()
        var reachabilityStatusDTO: ReachabilityStatusDTO?

        reachabilityStatus.map {
            reachabilityStatusDTO = ReachabilityStatusDTO.from(model: $0)
        }

        let metrics = BackgroundExcecutionMetrics(
            epochInMilliseconds: createEpoch(),
            batteryLevel: hardwareCapabilities.getBatterylevel(),
            batteryState: hardwareCapabilities.getBatteryState(),
            freeRamStorage: hardwareCapabilities.getFreeRam(),
            simState: conectivityCapabilities.getSimState().rawValue,
            hasInternetConnectionProvidedByCarrier: hasInternetConnectionProvidedByCarrier,
            currentlyOverWifi: conectivityCapabilities.isOverWifi,
            currentNetInterface: conectivityCapabilities.netInterfaceName,
            excludedTunnelAddresses: conectivityCapabilities.getExcludedTunnelAddresses(),
            proxyHttp: conectivityCapabilities.getHTTPProxy(),
            proxyHttps: conectivityCapabilities.getHTTPSProxy(),
            socksEnable: conectivityCapabilities.isSOCKSEnable(),
            availableNetworks: availableNetworksDTO,
            reachabilityStatus: reachabilityStatusDTO,
            totalRamStorage: hardwareCapabilities.getTotalRam(),
            osVersion: osVersionString
        )

        let encoder = JSONEncoder()
        guard let metricsAsData = try? encoder.encode(metrics) else {
            return nil
        }

        return String(decoding: metricsAsData, as: UTF8.self)
    }

    private func createEpoch() -> Int64 {
        /// timeIntervalSince1970 provides miliseconds on decimal part so we can get epoch time as int in miliseconds.
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

struct BackgroundExcecutionMetrics: Encodable {
    let epochInMilliseconds: Int64
    let batteryLevel: Float
    let batteryState: String
    let freeRamStorage: Int64
    let simState: String
    let hasInternetConnectionProvidedByCarrier: Bool?
    let currentlyOverWifi: Bool?
    let currentNetInterface: String
    let excludedTunnelAddresses: String
    let proxyHttp: String
    let proxyHttps: String
    let socksEnable: Int
    let availableNetworks: AvailableNetworksDTO?
    let reachabilityStatus: ReachabilityStatusDTO?
    let totalRamStorage: UInt64
    let osVersion: String
}

struct AvailableNetworksDTO: Encodable {
    var wifi: Bool
    var loopback: Bool
    var wiredEthernet: Bool
    var cellular: Bool
    var other: Bool

    static func from(model: AvailableNetworks) -> AvailableNetworksDTO {
        return AvailableNetworksDTO(wifi: model.wifi,
                                    loopback: model.loopback,
                                    wiredEthernet: model.wiredEthernet,
                                    cellular: model.cellular,
                                    other: model.other)
    }
}
