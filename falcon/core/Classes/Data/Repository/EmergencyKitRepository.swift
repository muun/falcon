//
//  EmergencyKitVerificationCodesRepository.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 16/11/2020.
//

import Foundation

public class EmergencyKitRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    // Store a verification code in the verification codes array
    public func store(code: String) {
        var updatedCodes = [String]()
        if let verificationCodes = preferences.array(forKey: .emergencyKitVerificationCodes) as? [String] {
            updatedCodes = verificationCodes
        }

        if !updatedCodes.contains(code) {
            updatedCodes.append(code)
        }

        preferences.set(value: updatedCodes, forKey: .emergencyKitVerificationCodes)
    }

    // Returns a boolean indicated if a code is old. i.e: is stored in the old codes array
    public func isOld(code: String) -> Bool {
        guard let verificationCodes = preferences.array(forKey: .emergencyKitVerificationCodes) as? [String] else {
            return false
        }

        return verificationCodes.contains(code)
    }

}
