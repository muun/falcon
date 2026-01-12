//
//  LocaleTimeZoneProvider.swift
//
//  Created by Ramiro Repetto on 23/07/2024.
//

import Foundation

public class LocaleTimeZoneProvider {

    func getTimezoneId() -> String {
        let tzc = TimeZone.current
        return String(tzc.identifier.prefix(100))
    }

    func getTimeZoneOffsetInSeconds() -> Int {
        let timezoneOffsetInSeconds = TimeZone.current.secondsFromGMT()
        return timezoneOffsetInSeconds
    }

    func getRegionCode() -> String {
        let locale = Locale.current
        return locale.regionCode ?? SignalConstants.empty
    }

    func getLanguage() -> String {
        return Locale.current.identifier
    }

    func getCurrencyCode() -> String {
        let locale = Locale.current
        return locale.currencyCode ?? SignalConstants.empty
    }

    func createEpochInMiliseconds() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

    private struct SignalConstants {
        static let empty = ""
    }
}
