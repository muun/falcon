//
//  LocaleTimeZoneProvider.swift
//  core-all
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

    func getDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        return dateFormatter.dateFormat ?? SignalConstants.empty
    }

    func getMeasurementSystem() -> String {
        let locale = Locale.current
        if #available(iOS 16, *) {
            let measurementSystem = locale.measurementSystem
            return measurementSystem.identifier
        } else {
            return SignalConstants.unknown
        }
    }

    func getCalendarIdentifier() -> String {
        let locale = Locale.current
        let calendarIdentifier = locale.calendar.identifier
        return String(describing: calendarIdentifier)
    }

    private struct SignalConstants {
        static let empty = ""
        static let unknown = "UNKNOWN"
    }
}
