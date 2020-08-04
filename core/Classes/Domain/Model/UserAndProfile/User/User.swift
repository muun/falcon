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
    public var email: String?
    let phoneNumber: PhoneNumber?
    let profilePictureUrl: String?
    public var primaryCurrency: String
    public var isEmailVerified: Bool
    let hasPasswordChallengeKey: Bool
    let hasRecoveryCodeChallengeKey: Bool
    let hasP2PEnabled: Bool

    // These properties have te be optional because the object user was stored on preferences without these fields
    // in previous versions:
    var hasExportedKeys: Bool?
    public let createdAt: Date?
    var emergencyKitLastExportedDate: Date?

    func hasExportedEmergencyKit() -> Bool {
        return emergencyKitLastExportedDate != nil
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
}
