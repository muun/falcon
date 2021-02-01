//
//  SetUpRecoveryCodeWording.swift
//  falcon
//
//  Created by Manu Herrera on 04/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

// This enum is used for all the conditional wording of the set up email + password flow
enum SetUpRecoveryCodeWording {
    case emailNotSetup
    case emailSetup

    // Action card
    func securityCenterCardTitle() -> NSAttributedString {
        return NSAttributedString(string: L10n.SetUpRecoveryCodeWording.s1)
    }

    func securityCenterCardDescription(emailSkipped: Bool) -> String {
        switch self {
        case .emailNotSetup:
            if emailSkipped {
                return L10n.SetUpRecoveryCodeWording.s2
            }
            return L10n.SetUpRecoveryCodeWording.s3
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s4
        }
    }

    func securityCenterCardCompletedTitle() -> NSAttributedString {
        return NSAttributedString(string: L10n.SetUpRecoveryCodeWording.s5)
    }

    func securityCenterCardCompletedDescription(email: String?) -> NSAttributedString {
        switch self {
        case .emailNotSetup:
            return L10n.SetUpRecoveryCodeWording.s6
                .attributedForDescription()
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s7
                .attributedForDescription()
        }
    }

    // Priming
    func primingTitle() -> String {
        switch self {
        case .emailNotSetup:
            return L10n.SetUpRecoveryCodeWording.s8
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s1
        }
    }

    func primingDescription() -> NSAttributedString {
        switch self {
        case .emailNotSetup:
            return L10n.SetUpRecoveryCodeWording.s10
                .attributedForDescription(alignment: .center)
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s11
                .attributedForDescription(alignment: .center)
        }
    }

    // Navigation
    func navigationTitle() -> String {
        switch self {
        case .emailNotSetup:
            return L10n.SetUpRecoveryCodeWording.s8
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s13
        }
    }

    // Finish
    func firstUnderstandingCheck() -> String {
        switch self {
        case .emailNotSetup:
            return L10n.SetUpRecoveryCodeWording.s14
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s15
        }
    }

    func secondUnderstandingCheck() -> String {
        // Same for both flows
        return L10n.SetUpRecoveryCodeWording.s16
    }

    // Success
    func successTitle() -> String {
        return L10n.SetUpRecoveryCodeWording.s17
    }

    func successDescription() -> String {
        switch self {
        case .emailNotSetup:
            return L10n.SetUpRecoveryCodeWording.s18
        case .emailSetup:
            return L10n.SetUpRecoveryCodeWording.s19
        }
    }
}
