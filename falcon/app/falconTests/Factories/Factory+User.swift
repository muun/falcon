//
//  Factory+User.swift
//  falconTests
//
//  Created by Federico Bond on 13/05/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
@testable import core

extension Factory {

    static func user(createdAt: Date = Date()) -> User {
        return User(
            id: 1,
            firstName: nil,
            lastName: nil,
            email: nil,
            phoneNumber: nil,
            profilePictureUrl: nil,
            primaryCurrency: "USD",
            isEmailVerified: true,
            hasPasswordChallengeKey: false,
            hasRecoveryCodeChallengeKey: false,
            hasP2PEnabled: false,
            hasExportedKeys: false,
            createdAt: createdAt,
            emergencyKitLastExportedDate: nil
        )
    }

}
