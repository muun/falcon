//
//  User.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

struct UserJson: Codable {

    let id: Int
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNumber: PhoneNumberJson?
    let profilePictureUrl: String?
    let primaryCurrency: String
    let isEmailVerified: Bool
    let hasPasswordChallengeKey: Bool
    let hasRecoveryCodeChallengeKey: Bool
    let hasP2PEnabled: Bool
    let hasExportedKeys: Bool
    let createdAt: Date?
    let preferences: UserPreferences?
    let emergencyKit: ExportEmergencyKitJson?
    let exportedKitVersions: [Int]
}

struct PhoneNumberJson: Codable {
    let isVerified: Bool
    let number: String
}

enum VerificationTypeJson: String, Codable {
    case SMS
    case CALL
}

struct ExportEmergencyKitJson: Codable {
    let lastExportedAt: Date
    let verificationCode: String
    let verified: Bool
    let version: Int
    let method: Method?

    enum Method: String, RawRepresentable, Codable {
        case icloud = "ICLOUD"
        case drive = "DRIVE"
        case manual = "MANUAL"
    }
}
