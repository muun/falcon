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
    public let email: String
    let phoneNumber: PhoneNumber?
    let profilePictureUrl: String?
    public var primaryCurrency: String
    let isEmailVerified: Bool
    let hasPasswordChallengeKey: Bool
    let hasRecoveryCodeChallengeKey: Bool
    let hasP2PEnabled: Bool

}

struct PhoneNumber: Codable {
    let isVerified: Bool
    let number: String
}

enum VerificationType: String {
    case SMS
    case CALL
}
