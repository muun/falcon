//
//  BackgroundExcecutionMetricsProvider.swift
//
//  Created by Lucas Serruya on 17/01/2023.
//

import Foundation

class BackgroundExecutionMetricsProvider {
    private let asciiSanitizer: AsciiUtils
    private let metricsProvider: MetricsProvider

    init(
        asciiSanitizer: AsciiUtils = AsciiUtils(),
        metricsProvider: MetricsProvider
    ) {
        self.asciiSanitizer = asciiSanitizer
        self.metricsProvider = metricsProvider
    }

    func run() -> String? {
        let metrics = BackgroundExecutionMetrics(
            epochInMilliseconds: metricsProvider.createEpochInMiliseconds,
            batteryLevel: metricsProvider.batterylevel,
            batteryState: metricsProvider.batteryState,
            simState: metricsProvider.simState.rawValue,
            hasInternetConnectionProvidedByCarrier: metricsProvider
                .hasInternetConnectionProvidedByCarrier,
            currentlyOverWifi: metricsProvider.isOverWifi,
            currentNetInterface: metricsProvider.netInterfaceName,
            excludedTunnelAddressesType: metricsProvider.excludedTunnelAddressesType,
            proxyHttpType: metricsProvider.proxyHTTPType,
            proxyHttpsType: metricsProvider.proxyHTTPSType,
            socksEnable: metricsProvider.socksEnable,
            availableNetworks: metricsProvider.availableNetworks,
            reachabilityStatus: metricsProvider.reachabilityStatus,
            osVersion: metricsProvider.osVersion,
            iosTimeZoneId: metricsProvider.timezoneId,
            iosCurrencyCode: metricsProvider.currencyCode,
            language: metricsProvider.language,
            regionCode: metricsProvider.regionCode,
            timeZoneOffsetInSeconds: metricsProvider.timeZoneOffsetInSeconds,
            storeCountry: metricsProvider.storeCountry
        )

        var metricsAsData: Data?
        do {
            let encoder = JSONEncoder()
            metricsAsData = try encoder.encode(metrics)
        } catch {
            Logger.log(error: error)
        }

        guard let metricsAsData = metricsAsData else {
            return nil
        }

        let jsonString = String(decoding: metricsAsData, as: UTF8.self)
        return asciiSanitizer.toSafeAscii(jsonString)
    }
}

struct BackgroundExecutionMetrics: Encodable {
    let epochInMilliseconds: Int64
    let batteryLevel: Float
    let batteryState: String
    let simState: String
    let hasInternetConnectionProvidedByCarrier: Bool?
    let currentlyOverWifi: Bool?
    let currentNetInterface: String
    let excludedTunnelAddressesType: Int
    let proxyHttpType: Int
    let proxyHttpsType: Int
    let socksEnable: Int
    let availableNetworks: AvailableNetworks?
    let reachabilityStatus: ReachabilityStatusDTO?
    let osVersion: String
    let iosTimeZoneId: String
    let iosCurrencyCode: String
    let language: String
    let regionCode: String
    let timeZoneOffsetInSeconds: Int
    let storeCountry: String
}
