//
//  User.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Libwallet

public struct User: Codable {

    public let id: Int
    let firstName: String?
    let lastName: String?
    /*
     Careful when using the email property.
     The correct way to guarantee that the user has an email setup is by asking for:
     `user.hasPasswordChallengeKey`
    */
    public var email: String?
    let phoneNumber: PhoneNumber?
    let profilePictureUrl: String?
    var primaryCurrency: String
    public var isEmailVerified: Bool
    var hasPasswordChallengeKey: Bool
    var hasRecoveryCodeChallengeKey: Bool
    let hasP2PEnabled: Bool

    // These properties have te be optional because the object user was stored on preferences
    // without these fields
    // in previous versions:
    var hasExportedKeys: Bool?
    public let createdAt: Date?
    @available(*, deprecated, message: "use emergencyKit")
    var emergencyKitLastExportedDate: Date?
    var emergencyKit: ExportEmergencyKit?
    var exportedKitVersions: [Int]?

    func hasExportedEmergencyKit() -> Bool {
        return emergencyKit != nil
    }

    public func primaryCurrencyWithValidExchangeRate(window: ExchangeRateWindow) -> String {
        guard primaryCurrency != "BTC" else {
            return "BTC"
        }

        do {
            // rate(for:) also rejects zero/negative/NaN rates, not just missing ones
            _ = try window.rate(for: primaryCurrency)
            return primaryCurrency
        } catch {
            // A present-but-invalid rate (zero/negative/NaN) is the anomaly worth reporting; a
            // missing currency is an expected, transient state and would only add noise.
            if let muunError = error as? MuunError,
               let windowError = muunError.kind as? ExchangeRateWindow.Errors,
               case .invalid(_, let rate, _) = windowError {
                // A plain NSError groups by callsite (not by message), so the offending rate can
                // live in the description without fragmenting the Crashlytics issue.
                Logger.log(error: NSError(
                    domain: "invalid_primary_exchange_rate",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey:
                        "Invalid primary rate for \(primaryCurrency): \(rate)"]
                ))
            }
            return "BTC"
        }
    }

    public func primaryCurrencyWithValidExchangeRate(window: NewopExchangeRateWindow) -> String {
        guard primaryCurrency != "BTC" else {
            return "BTC"
        }

        // rate() returns 0 for missing currencies, so this also covers the nil case
        let rate = window.rate(primaryCurrency)
        if rate.isUsableExchangeRate {
            return primaryCurrency
        }

        // Report a present-but-broken rate (negative/NaN). A 0 is indistinguishable from a
        // missing currency in this API, so we don't report it to avoid noise.
        if rate < 0 || rate.isNaN {
            // A plain NSError groups by callsite (not by message), so the offending rate can
            // live in the description without fragmenting the Crashlytics issue.
            Logger.log(error: NSError(
                domain: "invalid_primary_exchange_rate",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey:
                    "Invalid primary rate (newop) for \(primaryCurrency): \(rate)"]
            ))
        }
        return "BTC"
    }

    // This currency may not have a valid rate associated, use carefully.
    public func unsafeGetPrimaryCurrency() -> String {
        return primaryCurrency
    }

    public mutating func setPrimaryCurrency(_ currency: String) {
        primaryCurrency = currency
    }

    // This is used to transform the creation date of an user to a Support Identifier
    public func getSupportId() -> String? {
        guard let date = createdAt else {
            return nil
        }

        // Convert the date to epoch and remove the miliseconds
        let epoch = Int(date.timeIntervalSince1970).description

        // Get the last 8 characters
        var customId = String(epoch.suffix(8))

        // Insert a "-" in the middle to get two 4 characters chunks (1234-5678)
        customId.insert("-", at: customId.index(customId.startIndex, offsetBy: 4))
        return customId
    }

}

struct PhoneNumber: Codable {
    let isVerified: Bool
    let number: String
}

enum VerificationType: String {
    case SMS
    case CALL
}

public struct ExportEmergencyKit: Codable {
    let lastExportedAt: Date
    let verificationCode: String
    let verified: Bool
    let version: Int
    let method: Method?

    public init(
        lastExportedAt: Date,
        verificationCode: String,
        verified: Bool,
        version: Int,
        method: Method?
    ) {
        self.lastExportedAt = lastExportedAt
        self.verificationCode = verificationCode
        self.verified = verified
        self.version = version
        self.method = method
    }

    public enum Method: String, RawRepresentable, Codable {
        case icloud,
             drive,
             manual
    }
}

/*
 For instructions on adding new fields, see UserPreferences in common.
 */
public struct UserPreferences: Codable {
    public let receiveStrictMode: Bool
    public let seenNewHome: Bool
    public let seenLnurlFirstTime: Bool
    public let skippedEmailSetup: Bool
    public let defaultAddressType: AddressType
    public let receiveFormatPreference: ReceiveFormatPreference

    public func copy(
        receiveStrictMode: Bool? = nil,
        seenNewHome: Bool? = nil,
        seenLnurlFirstTime: Bool? = nil,
        skippedEmailSetup: Bool? = nil,
        defaultAddressType: AddressType? = nil,
        receiveFormatPreference: ReceiveFormatPreference? = nil
    ) -> UserPreferences {

        return UserPreferences(
            receiveStrictMode: receiveStrictMode ?? self.receiveStrictMode,
            seenNewHome: seenNewHome ?? self.seenNewHome,
            seenLnurlFirstTime: seenLnurlFirstTime ?? self.seenLnurlFirstTime,
            skippedEmailSetup: skippedEmailSetup ?? self.skippedEmailSetup,
            defaultAddressType: defaultAddressType ?? self.defaultAddressType,
            receiveFormatPreference: receiveFormatPreference ?? self.receiveFormatPreference
        )
    }
}
