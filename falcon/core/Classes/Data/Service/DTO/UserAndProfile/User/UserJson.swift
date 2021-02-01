//
//  User.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

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
    let emergencyKitLastExportedAt: Date?
    let preferences: UserPreferences?
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
}
