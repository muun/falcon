//
//  ConectivityCapabilitiesProvider.swift
//
//  Created by Lucas Serruya on 01/02/2023.
//

import Foundation
import Network
import CoreTelephony

public class ConectivityCapabilitiesProvider {
    public static let shared = ConectivityCapabilitiesProvider()
    // Maintained for legacy backward compability.
    var isOverWifi: Bool?
    var netInterfaceName: String = SignalConstants.empty
    var availableNetworks: AvailableNetworks?

    private var storedNetworkMonitor: Any?

    private var networkMonitor: NWPathMonitor {
        if storedNetworkMonitor == nil {
            storedNetworkMonitor = NWPathMonitor()
        }

        // swiftlint:disable force_cast
        return storedNetworkMonitor as! NWPathMonitor
    }

    public func startMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.availableNetworks = self?
                .retrieveAvailableNetworksBasedOn(availableInterfaces: path.availableInterfaces)
        }

        networkMonitor.start(queue: DispatchQueue(label: "availableNetworksMonitor"))
    }

    func getSimRegion() -> String {
        guard let carrier = CTTelephonyNetworkInfo()
            .serviceSubscriberCellularProviders?.values.first else {
            return SignalConstants.unknown
        }

        guard let isoCountry = carrier.isoCountryCode else {
            return SignalConstants.empty
        }

        if isoCountry == SIMStateDeprecatedValues.noISOCountryCode {
            return SignalConstants.deprecated
        }

        return isoCountry
    }

    func getSimState() -> SimState {
        let cellularProvidersCountryCodes = CTTelephonyNetworkInfo()
            .serviceSubscriberCellularProviders?
            .values
            .compactMap { $0.mobileCountryCode }
        guard let mobileCountryCodes = cellularProvidersCountryCodes, !mobileCountryCodes.isEmpty else {
            return .absent
        }

        if (mobileCountryCodes.contains { $0 == SIMStateDeprecatedValues.noMobileCountryCode }) {
            return .deprecated
        }

        return .ready
    }

    func hasInternetConnectionProvidedByCarrier() -> Bool {
        guard let radioAccess = CTTelephonyNetworkInfo()
            .serviceCurrentRadioAccessTechnology else {
            return false
        }
        return !radioAccess.isEmpty
    }

    func getExcludedTunnelAddresses() -> String {
        guard let cfDict = CFNetworkCopySystemProxySettings() else {
            return SignalConstants.unknown
        }
        let proxySettings = cfDict.takeRetainedValue() as NSDictionary
        if let value = proxySettings["ExceptionsList"] as? [String] {
            let stringArray = value.map { "\($0)" }
            return stringArray.joined(separator: ", ")
        }
        return SignalConstants.empty
    }

     func getHTTPProxy() -> String {
         return getProxySetting(
            key: .http,
            unknownValue: SignalConstants.unknown,
            defaultValue: SignalConstants.empty
         )
     }

     func getHTTPSProxy() -> String {
         return getProxySetting(
            key: .https,
            unknownValue: SignalConstants.unknown,
            defaultValue: SignalConstants.empty
         )
     }

     func isSOCKSEnable() -> Int {
         return getProxySetting(
            key: .socks,
            unknownValue: SignalConstants.intUnknown,
            defaultValue: SignalConstants.intDisabled
         )
     }

    func getCellularProviders() -> [SimData] {
        // Current connection related data
        let radiosData = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology ?? [:]
        // Sim related data
        let carriers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders ?? [:]

        return radiosData.map { (serviceId, radio) -> SimData in
            return SimData.from(
                    radioData: (serviceId: serviceId, radio: radio),
                    carriers: carriers
                )
        }
    }

    private func getProxySetting<T>(key: ProxyKey, unknownValue: T, defaultValue: T) -> T {
        guard let cfDict = CFNetworkCopySystemProxySettings() else {
            return defaultValue
        }
        let netSettings = cfDict.takeRetainedValue() as NSDictionary
        if let value = netSettings[key.rawValue] as? T {
            return value
        }
        return defaultValue
    }

    private func resetCachedAvailableNetworks() {
        availableNetworks = AvailableNetworks()
        isOverWifi = false
    }

    private func retrieveAvailableNetworksBasedOn(
        availableInterfaces: [NWInterface]
    ) -> AvailableNetworks {
        var availableNetworks = AvailableNetworks()

        isOverWifi = availableInterfaces.contains(where: { $0.type == .wifi })

        netInterfaceName = availableInterfaces.first?.name ?? SignalConstants.empty

        availableInterfaces.forEach {
            switch($0.type) {
            case .wifi:
                availableNetworks.wifi = true
            case .cellular:
                availableNetworks.cellular = true
            case .loopback:
                availableNetworks.loopback = true
            case .wiredEthernet:
                availableNetworks.wiredEthernet = true
            case .other:
                availableNetworks.other = true
            }
        }

        return availableNetworks
    }
}

enum SimState: String {
    case ready = "SIM_STATE_READY"
    case unknown = "SIM_STATE_UNKNOWN"
    case deprecated = "SIM_SDK_DEPRECATED"
    case absent = "SIM_STATE_ABSENT"
}

struct AvailableNetworks {
    var wifi: Bool
    var loopback: Bool
    var wiredEthernet: Bool
    var cellular: Bool
    var other: Bool

    init() {
        wifi = false
        loopback = false
        wiredEthernet = false
        cellular = false
        other = false
    }
}

enum ProxyKey: String {
    case http = "HTTPProxy"
    case https = "HTTPSProxy"
    case socks = "SOCKSEnable"
}

struct SimData: Encodable {
    var simRegion: String
    var simOperatorName: String
    var simCountryCode: String
    var simNetworkCode: String
    var mobileRadioType: String
    var serviceId: String

    static func from(
        radioData: (serviceId: String, radio: String),
        carriers: [String: CTCarrier]
    ) -> SimData {
        let (serviceId, radio) = radioData
        let carrier = carriers[serviceId]

        return SimData(
            simRegion: processProviderValue(
                carrier?.isoCountryCode,
                deprecatedValue: SIMStateDeprecatedValues.noISOCountryCode
            ),
            simOperatorName: processProviderValue(
                carrier?.carrierName,
                deprecatedValue: SIMStateDeprecatedValues.noCarrierName
            ),
            simCountryCode: processProviderValue(
                carrier?.mobileCountryCode,
                deprecatedValue: SIMStateDeprecatedValues.noMobileCountryCode
            ),
            simNetworkCode: processProviderValue(
                carrier?.mobileNetworkCode,
                deprecatedValue: SIMStateDeprecatedValues.noMobileNetworkCode
            ),
            mobileRadioType: radio,
            serviceId: serviceId
        )
    }

    static func processProviderValue(_ value: String?, deprecatedValue: String) -> String {
        guard let code = value, code != deprecatedValue else {
            return SignalConstants.deprecated
        }
        return code
    }
}

struct SignalConstants {
    static let empty = ""
    static let unknown = "UNKNOWN"
    static let deprecated = "DEPRECATED"
    
    static let intUnknown = -1
    static let intDisabled = 0
}

struct SIMStateDeprecatedValues {
    static let noMobileCountryCode = "65535"
    static let noMobileNetworkCode = "65535"
    static let noCarrierName = "--"
    static let noISOCountryCode = "--"
}
