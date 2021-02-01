//
//  SetupEmailWording.swift
//  falcon
//
//  Created by Manu Herrera on 04/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

// This enum is used for all the conditional wording of the set up email + password flow
enum SetUpEmailWording {
    case recoveryCodeNotSetup
    case recoveryCodeSetup

    // Action card
    func securityCenterCardTitle() -> NSAttributedString {
        return NSAttributedString(string: L10n.SetupEmailWording.s1)
    }

    func securityCenterCardDescription(emailSkipped: Bool) -> String {
        switch self {
        case .recoveryCodeNotSetup:
            if emailSkipped {
                return L10n.SetupEmailWording.s2
            }
            return L10n.SetupEmailWording.s3
        case .recoveryCodeSetup:
            return L10n.SetupEmailWording.s4
        }
    }

    func securityCenterCardCompletedTitle() -> NSAttributedString {
        return NSAttributedString(string: L10n.SetupEmailWording.s5)
    }

    func securityCenterCardCompletedDescription(email: String) -> NSAttributedString {
        let desc = L10n.SetupEmailWording.s6(email)
            .attributedForDescription()
            .set(bold: email, color: Asset.Colors.title.color)

        return desc
    }

    // Priming
    func primingTitle() -> String {
        switch self {
        case .recoveryCodeNotSetup:
            return L10n.SetupEmailWording.s1
        case .recoveryCodeSetup:
            return L10n.SetupEmailWording.s8
        }
    }

    func primingDescription() -> String {
        switch self {
        case .recoveryCodeNotSetup:
            return L10n.SetupEmailWording.s18
        case .recoveryCodeSetup:
            return L10n.SetupEmailWording.s19
        }
    }

    // Navigation
    func navigationTitle() -> String {
        switch self {
        case .recoveryCodeNotSetup:
            return L10n.SetupEmailWording.s1
        case .recoveryCodeSetup:
            return L10n.SetupEmailWording.s10
        }
    }

    // Enter email
    func enterEmailTitle() -> String {
        return L10n.SetupEmailWording.s11 // Same for both flows
    }

    func enterEmailDescription() -> NSAttributedString {
        let underline = L10n.SetupEmailWording.s12
        return L10n.SetupEmailWording.s13
            .attributedForDescription()
            .set(underline: underline, color: Asset.Colors.muunBlue.color)
    }

    // Finish
    func firstUnderstandingCheck() -> String {
        // Same for both flows
        return L10n.SetupEmailWording.s14
    }

    func secondUnderstandingCheck() -> String {
        // Same for both flows
        return L10n.SetupEmailWording.s15
    }

    // Success
    func successTitle() -> String {
        // Same for both flows
        return L10n.SetupEmailWording.s16
    }

    func successDescription() -> String {
        // Same for both flows
        return L10n.SetupEmailWording.s17
    }
}
