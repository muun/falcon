//
//  ConectivityCapabilitiesProvider.swift
//
//  Created by Lucas Serruya on 01/02/2023.
//

import Foundation
import Network
import CoreTelephony

public class ConectivityCapabilitiesProvider {
    // Maintained for legacy backward compability.
    var isOverWifi: Bool?
    var netInterfaceName: String = SignalConstants.empty
    var availableNetworks: AvailableNetworks?
    private let defaultCanonicalExcludedAddresses = ["*.local", "169.254/16"]

    private let internalRanges: [(mask: UInt32, value: UInt32)] = [
        (0xFF000000, 0x0A000000),   // 10.0.0.0/8
        (0xFFF00000, 0xAC100000),   // 172.16.0.0/12
        (0xFFFF0000, 0xC0A80000),   // 192.168.0.0/16
        (0xFFFF0000, 0xA9FE0000)    // 169.254.0.0/16
    ]

    private let knownInternalHosts: Set<String> = [
        "proxy.local",
        "proxy",
        "local"
    ]
    private let knownLoopbackHosts: Set<String> = [
        "localhost",
        "localhost.localdomain",
        "loopback"
    ]

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

    func excludedTunnelAddressesType() -> Int {
        guard let proxySettings = getProxySettingsDict() else {
            return AddressesType.unknown.rawValue
        }
        guard let value = proxySettings["ExceptionsList"] as? [String] else {
            return AddressesType.empty.rawValue
        }

        let normalized = value.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.sorted()
        let canonical = defaultCanonicalExcludedAddresses.sorted()
        if normalized.isEmpty {
            return AddressesType.empty.rawValue
        } else if normalized == canonical {
            return AddressesType.canonical.rawValue
        } else {
            return AddressesType.other.rawValue
        }
    }

     func getHTTPProxyType() -> Int {
         return getProxyType(key: .http)
     }

     func getHTTPSProxyType() -> Int {
         return getProxyType(key: .https)
     }

     func isSOCKSEnable() -> Int {
         guard let settings = getProxySettingsDict() else {
             return SignalConstants.intUnknown
         }
         if let value = settings[ProxyKey.socks] as? NSNumber {
             return value.intValue
         }
         return SignalConstants.intDisabled
     }
    
    private func getProxyType(key: ProxyKey) -> Int {
        guard let settings = getProxySettingsDict() else {
            return AddressesType.unknown.rawValue
        }
        if let value = settings[key.rawValue] as? String {
            return classifyHost(value)
        }
        return AddressesType.empty.rawValue
    }

    private func getProxySettingsDict() -> NSDictionary? {
        guard let cfDict = CFNetworkCopySystemProxySettings() else {
            return nil
        }
        return cfDict.takeRetainedValue() as NSDictionary
    }

    private func isPrivateIPv4(_ hostValue: String) -> Bool {
        var addr = in_addr()

        if inet_pton(AF_INET, hostValue, &addr) == 1 {
            let ipNum = UInt32(bigEndian: addr.s_addr)

            for (mask, value) in internalRanges where (ipNum & mask) == value {
                return true
            }
        }
        return false
    }

    private func isUniqueLocalAddressIPv6(_ ip: IPv6Address) -> Bool {
        let b0 = ip.rawValue[0]
        return (b0 & 0xFE) == 0xFC   // fc00::/7  (fcxx or fdxx)
    }

    private func classifyIPv4(_ host: String, _ ipv4: IPv4Address) -> Int {
        if ipv4.isLoopback {
            return AddressesType.localhost.rawValue
        }
        if ipv4.isLinkLocal {
            return AddressesType.internalRange.rawValue
        }
        if isPrivateIPv4(host) {
            return AddressesType.internalRange.rawValue
        }
        return AddressesType.other.rawValue
    }

    private func classifyIPv6(_ host: String, _ ipv6: IPv6Address) -> Int {
        if ipv6.isLoopback {
            return AddressesType.localhost.rawValue
        }
        if ipv6.isLinkLocal { // fe80::/10
            return AddressesType.internalRange.rawValue
        }
        if isUniqueLocalAddressIPv6(ipv6) {
            return AddressesType.internalRange.rawValue
        }
        return AddressesType.other.rawValue
    }

    private func classifyName(_ host: String) -> Int {
        let lower = host.lowercased()

        if knownLoopbackHosts.contains(lower) {
            return AddressesType.localhost.rawValue
        }

        if knownInternalHosts.contains(lower) || lower.hasSuffix(".local") {
            return AddressesType.internalRange.rawValue
        }

        return AddressesType.other.rawValue
    }

    private func classifyHost(_ hostValue: String?) -> Int {
        guard let host = hostValue?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !host.isEmpty else {
            return AddressesType.empty.rawValue
        }

        if let ipv4 = IPv4Address(host) {
            return classifyIPv4(host, ipv4)
        }

        if let ipv6 = IPv6Address(host) {
            return classifyIPv6(host, ipv6)
        }

        return classifyName(host)
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

struct AvailableNetworks: Encodable {
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

struct SignalConstants {
    static let empty = ""
    static let unknown = "UNKNOWN"
    
    static let intUnknown = -1
    static let intDisabled = 0
}

struct SIMStateDeprecatedValues {
    static let noMobileCountryCode = "65535"
}

private enum AddressesType: Int {
    case localhost = 4
    case other = 3
    case internalRange = 2
    case empty = 1
    case canonical = 0
    case unknown = -1
}
