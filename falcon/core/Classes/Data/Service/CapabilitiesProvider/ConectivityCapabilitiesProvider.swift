//
//  ConectivityCapabilitiesProvider.swift
//  core-all
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
    var availableNetworks: AvailableNetworks?

    private var storedNetworkMonitor: Any?

    private var networkMonitor: NWPathMonitor {
        if storedNetworkMonitor == nil {
            storedNetworkMonitor = NWPathMonitor()
        }

        return storedNetworkMonitor as! NWPathMonitor
    }
    
    public func startMonitoring() {
        if #available(iOS 12.0, *) {
            networkMonitor.pathUpdateHandler = { [weak self] path in
                self?.availableNetworks = self?.retrieveAvailableNetworksBasedOn(availableInterfaces: path.availableInterfaces)
            }

            networkMonitor.start(queue: DispatchQueue(label: "availableNetworksMonitor"))
        }
    }

    func getSimState() -> SimState {
        if #available(iOS 12.0, *) {
            let countryCodeDeprecatedValueIndicator = "65535"

            let mobileCountryCodes = CTTelephonyNetworkInfo()
                .serviceSubscriberCellularProviders?
                .values
                .compactMap { $0.mobileCountryCode }
            guard let mobileCountryCodes = mobileCountryCodes, !mobileCountryCodes.isEmpty else {
                return .absent
            }

            if (mobileCountryCodes.contains { $0 == countryCodeDeprecatedValueIndicator }) {
                return .deprecated
            }

            return .ready
        }
        return .unknown
    }

    func hasInternetConnectionProvidedByCarrier() -> Bool? {
        if #available(iOS 12.0, *) {
            guard let radioAccess = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology else {
                return false
            }
            return !radioAccess.isEmpty
        }
        return nil
    }

    private func resetCachedAvailableNetworks() {
        availableNetworks = AvailableNetworks()
        isOverWifi = false
    }

    private func retrieveAvailableNetworksBasedOn(availableInterfaces: [NWInterface]) -> AvailableNetworks {
        var availableNetworks = AvailableNetworks()

        isOverWifi = availableInterfaces.contains(where: { $0.type == .wifi })

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
