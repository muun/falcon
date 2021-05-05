//
//  AnalyticsHelper.swift
//  falcon
//
//  Created by Manu Herrera on 31/03/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseCore
import core

class AnalyticsHelper {

    // This constants can be found on: https://support.google.com/firebase/answer/9237506?hl=en
    private static let maxLengthUserPropertyName = 25
    private static let maxLengthUserPropertyValue = 36
    private static let maxLengthEventName = 40
    private static let maxLengthEventParameterName = 40
    private static let maxLengthEventParameterValue = 100

    private static let crashlytics = Crashlytics.crashlytics()

    private static let deviceParams: [String: Int] = [
        "height": Int(UIScreen.main.bounds.height),
        "width": Int(UIScreen.main.bounds.width),
        "scale": Int(UIScreen.main.scale)
    ]

    static func configure() {
        guard let firebaseOptions = FirebaseOptions(contentsOfFile: Environment.current.firebaseOptionsPath)
            else { Logger.fatal("failed to load firebase") }
        FirebaseApp.configure(options: firebaseOptions)
    }

    // MARK: User properties

    static func setUserProperty(id: String?) {
        Analytics.setUserID(id)
    }

    static func setUserProperty(_ value: String, forName name: String) {

        guard name.count <= maxLengthUserPropertyName  else {
            Logger.fatal("Property name: \(name) can't be longer than \(maxLengthUserPropertyName) characters")
        }

        if value.count <= maxLengthUserPropertyValue {
            Analytics.setUserProperty(value, forName: name)
        } else {
            // Truncate value to 36 chars
            Analytics.setUserProperty(value.truncate(maxLength: maxLengthUserPropertyValue), forName: name)
        }
    }

    // MARK: Crashlytics

    static func setCrashlyticsUserId(_ id: String?) {
        crashlytics.setUserID(id ?? "")
    }

    static func recordErrorToCrashlytics(_ err: Error, additionalInfo: [AnyHashable: Any]? = nil) {
        let tempNSError = err as NSError
        var currentUserInfo = tempNSError.userInfo
        additionalInfo?.forEach { (key, value) in
          currentUserInfo["\(key)"] = value
        }
        let updatedNSError = NSError(domain: tempNSError.domain, code: tempNSError.code, userInfo: currentUserInfo)
        crashlytics.record(error: updatedNSError)
    }

    // MARK: Analytics

    static func setAnalyticsCollection(enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }

    static func logEvent(_ event: String, parameters: [String: Any]? = nil) {
        let eventName = "e_\(event)"

        actuallyLogEvent(eventName, parameters: parameters)
    }

    static func logScreen(_ name: String, parameters: [String: Any]?) {
        Analytics.setScreenName(name, screenClass: nil)
        let screenName = "s_\(name)"

        actuallyLogEvent(screenName, parameters: parameters)
    }

    private static func actuallyLogEvent(_ event: String, parameters: [String: Any]? = nil) {
        let finalParams = addDeviceParams(to: parameters)

        if isValidEventName(event), areValidParameters(parameters: finalParams) {
            Analytics.logEvent(event, parameters: finalParams)
            Logger.log(
                .info,
                "Event: '\(event)' with parameters: \(finalParams.description) logged to Firebase Analytics"
            )
        } else {
            Logger.log(
                .err,
                """
                We are not logging this event because either:
                * it's name contains illegal characters or its too long: \(event)
                * Or some of its parameters contains illegal characters or are too long:
                \(finalParams.description)
                """
            )
            #if DEBUG
            fatalError("We are not logging this event: \(event). Parameters: \(finalParams.description)")
            #endif
        }
    }

    private static func isValidEventName(_ name: String) -> Bool {
        // The name of the event should contain 1 to 40 alphanumeric characters or underscores
        return !name.isEmpty
            && name.range(of: "^[a-zA-Z0-9_]*$", options: .regularExpression) != nil
            && name.count <= maxLengthEventName
    }

    private static func isValidParameterName(_ name: String) -> Bool {
        // The name of the event's parameter should contain 1 to 40 alphanumeric characters or underscores
        return !name.isEmpty
            && name.range(of: "^[a-zA-Z0-9_]*$", options: .regularExpression) != nil
            && name.count <= maxLengthEventParameterName
    }

    private static func isValidParameterValue(_ value: String) -> Bool {
        // The name of the event's parameter value should contain 1 to 100 characters
        // We don't need the regex for parameter values
        return !value.isEmpty && value.count <= maxLengthEventParameterValue
    }

    private static func areValidParameters(parameters: [String: Any]?) -> Bool {
        var validity = true

        if let p = parameters {
            p.keys.forEach { (name) in
                if !isValidParameterName(name) {
                    validity = false
                }
            }

            p.values.forEach { (value) in
                if !isValidParameterValue(String(describing: value)) {
                    validity = false
                }
            }
        }

        return validity
    }

    private static func addDeviceParams(to params: [String: Any]?) -> [String: Any] {
        var finalParams: [String: Any] = params ?? [:]
        finalParams.merge(deviceParams) { (_, new) in new }
        return finalParams
    }
}
