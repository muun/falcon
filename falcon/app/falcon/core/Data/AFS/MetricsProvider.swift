//
//  MetricsProvider.swift
//  falcon
//
//  Created by Ramiro Repetto on 15/10/2025.
//  Copyright © 2025 muun. All rights reserved.
//
import Foundation

public class MetricsProvider {

    private let localeTimeZoneProvider: LocaleTimeZoneProvider
    private let storeKitCapabilitiesProvider: StoreKitCapabilitiesProvider
    private let conectivityCapabilitiesProvider: ConectivityCapabilitiesProvider
    private let hardwareCapabilitiesProvider: HardwareCapabilitiesProvider
    private let processInfoProvider: ProcessInfoProvider
    private let reachabilityProvider: ReachabilityProvider
    private let deviceCheckDataProvider: DeviceCheckDataProvider
    private let appInfoProvider: AppInfoProvider
    
    init(
        localeTimeZoneProvider: LocaleTimeZoneProvider,
        storeKitCapabilitiesProvider: StoreKitCapabilitiesProvider,
        conectivityCapabilitiesProvider: ConectivityCapabilitiesProvider,
        hardwareCapabilitiesProvider: HardwareCapabilitiesProvider,
        processInfoProvider: ProcessInfoProvider,
        reachabilityProvider: ReachabilityProvider,
        deviceCheckDataProvider: DeviceCheckDataProvider,
        appInfoProvider: AppInfoProvider
    ) {
        self.localeTimeZoneProvider = localeTimeZoneProvider
        self.storeKitCapabilitiesProvider = storeKitCapabilitiesProvider
        self.conectivityCapabilitiesProvider = conectivityCapabilitiesProvider
        self.hardwareCapabilitiesProvider = hardwareCapabilitiesProvider
        self.processInfoProvider = processInfoProvider
        self.reachabilityProvider = reachabilityProvider
        self.deviceCheckDataProvider = deviceCheckDataProvider
        self.appInfoProvider = appInfoProvider
    }

    var createEpochInMiliseconds: Int64 {
        return localeTimeZoneProvider.createEpochInMiliseconds()
    }

    var timezoneId: String {
        return localeTimeZoneProvider.getTimezoneId()
    }

    var currencyCode: String {
        return localeTimeZoneProvider.getCurrencyCode()
    }

    var language: String {
        return localeTimeZoneProvider.getLanguage()
    }

    var regionCode: String {
        return localeTimeZoneProvider.getRegionCode()
    }

    var timeZoneOffsetInSeconds: Int {
        return localeTimeZoneProvider.getTimeZoneOffsetInSeconds()
    }

    var storeCountry: String {
        return storeKitCapabilitiesProvider.getStoreCountry()
    }

    var simState: SimState {
        return conectivityCapabilitiesProvider.getSimState()
    }

    var hasInternetConnectionProvidedByCarrier: Bool {
        return conectivityCapabilitiesProvider.hasInternetConnectionProvidedByCarrier()
    }

    var isOverWifi: Bool? {
        return conectivityCapabilitiesProvider.isOverWifi
    }

    var netInterfaceName: String {
        return conectivityCapabilitiesProvider.netInterfaceName
    }

    var excludedTunnelAddressesType: Int {
        return conectivityCapabilitiesProvider.excludedTunnelAddressesType()
    }

    var proxyHTTPType: Int {
        return conectivityCapabilitiesProvider.getHTTPProxyType()
    }

    var proxyHTTPSType: Int {
        return conectivityCapabilitiesProvider.getHTTPSProxyType()
    }

    var socksEnable: Int {
        return conectivityCapabilitiesProvider.isSOCKSEnable()
    }

    var availableNetworks: AvailableNetworks? {
        return conectivityCapabilitiesProvider.availableNetworks
    }

    var batterylevel: Float {
        return hardwareCapabilitiesProvider.getBatterylevel()
    }

    var batteryState: String {
        return hardwareCapabilitiesProvider.getBatteryState()
    }

    var isSoftDevice: Bool {
        hardwareCapabilitiesProvider.isSoftDevice()
    }

    var softDeviceName: String? {
        hardwareCapabilitiesProvider.getSoftDeviceName()
    }

    var hasGyro: Bool {
        hardwareCapabilitiesProvider.hasGyro()
    }

    var osVersion: String {
        processInfoProvider.getOsVersion()
    }

    var reachabilityStatus: ReachabilityStatusDTO? {
        return reachabilityProvider.getStatus()
    }

    var appDisplayName: String {
        return appInfoProvider.getAppDisplayName()
    }

    var appId: String {
        return appInfoProvider.getAppId()
    }

    var appName: String {
        return appInfoProvider.getAppName()
    }

    var appPrimaryIconHash: String {
        return appInfoProvider.getAppPrimaryIconHash()
    }

    var installSource: Int {
        return appInfoProvider.getInstallSource().rawValue
    }

    var deviceCheckToken: String {
        return deviceCheckDataProvider.getDeviceCheckToken()
    }

    var fallbackDeviceToken: String {
        return deviceCheckDataProvider.getFallbackDeviceToken()
    }
}
