//
//  User.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

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

    // These properties have te be optional because the object user was stored on preferences without these fields
    // in previous versions:
    var hasExportedKeys: Bool?
    public let createdAt: Date?
    var emergencyKitLastExportedDate: Date?

    func hasExportedEmergencyKit() -> Bool {
        return emergencyKitLastExportedDate != nil
    }

    public func primaryCurrencyWithValidExchangeRate(window: ExchangeRateWindow) -> String {
        if primaryCurrency != "BTC" && window.rates[primaryCurrency] != nil {
            return primaryCurrency
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
}

struct PhoneNumber: Codable {
    let isVerified: Bool
    let number: String
}

enum VerificationType: String {
    case SMS
    case CALL
}

struct ExportEmergencyKit: Codable {
    let lastExportedAt: Date
    let verificationCode: String
    let verified: Bool
}

/*
 For instructions on adding new fields, see UserPreferences in common.
 */
public struct UserPreferences: Codable {
    public let receiveStrictMode: Bool
    public let seenNewHome: Bool

    public func copy(receiveStrictMode: Bool? = nil, seenNewHome: Bool? = nil) -> UserPreferences {
        return UserPreferences(
            receiveStrictMode: receiveStrictMode ?? self.receiveStrictMode,
            seenNewHome: seenNewHome ?? self.seenNewHome
        )
    }
}
