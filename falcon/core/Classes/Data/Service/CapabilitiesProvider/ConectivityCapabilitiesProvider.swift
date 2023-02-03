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
    var isOverWifi: Bool?
    
    public func startMonitoring() {
        if #available(iOS 12.0, *) {
            let networkMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
            networkMonitor.pathUpdateHandler = { [weak self] path in
                /// This closure is called every time the connection status changes
                DispatchQueue.main.async {
                    switch path.status {
                    case .satisfied:
                        self?.isOverWifi = true
                    default:
                        self?.isOverWifi = false
                    }
                }
            }
            networkMonitor.start(queue: DispatchQueue(label: "monitorWiFi"))
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
}

enum SimState: String {
    case ready = "SIM_STATE_READY"
    case unknown = "SIM_STATE_UNKNOWN"
    case deprecated = "SIM_SDK_DEPRECATED"
    case absent = "SIM_STATE_ABSENT"
}
