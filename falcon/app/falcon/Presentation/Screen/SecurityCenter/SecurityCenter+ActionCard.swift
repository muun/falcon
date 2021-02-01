//
//  SecurityCenter+ActionCard.swift
//  falcon
//
//  Created by Manu Herrera on 22/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

extension ActionCard {

    static func emailIncomplete(wording: SetUpEmailWording, state: ActionCardState) -> ActionCardModel {
        let emailSkipped = state == .skipped ? true : false
        return ActionCardModel(
            title: wording.securityCenterCardTitle(),
            description: wording.securityCenterCardDescription(emailSkipped: emailSkipped).attributedForDescription(),
            nextViewController: EmailPrimingViewController(wording: wording),
            stemNumber: "1",
            stepImage: nil,
            state: state
        )
    }

    static func emailComplete(wording: SetUpEmailWording, email: String) -> ActionCardModel {
        return ActionCardModel(
            title: wording.securityCenterCardCompletedTitle(),
            description: wording.securityCenterCardCompletedDescription(email: email),
            nextViewController: nil,
            stemNumber: nil,
            stepImage: nil,
            state: .done
        )
    }

    static func recoveryCodeIncomplete(wording: SetUpRecoveryCodeWording, state: ActionCardState, emailSkipped: Bool)
    -> ActionCardModel {
        return ActionCardModel(
            title: wording.securityCenterCardTitle(),
            description: wording.securityCenterCardDescription(emailSkipped: emailSkipped).attributedForDescription(),
            nextViewController: RecoveryCodePrimingViewController(wording: wording),
            stemNumber: "2",
            stepImage: nil,
            state: state
        )
    }

    static func recoveryCodeComplete(wording: SetUpRecoveryCodeWording, email: String? = nil) -> ActionCardModel {
        return ActionCardModel(
            title: wording.securityCenterCardCompletedTitle(),
            description: wording.securityCenterCardCompletedDescription(email: email),
            nextViewController: nil,
            stemNumber: nil,
            stepImage: nil,
            state: .done
        )
    }

    static func exportKeysComplete() -> ActionCardModel {
        return ActionCardModel(
            title: NSAttributedString(string: L10n.SecurityCenter.s1),
            description: L10n.SecurityCenter.s7
                .attributedForDescription()
                .set(underline: L10n.SecurityCenter.s2, color: Asset.Colors.muunBlue.color),
            nextViewController: RecoveryToolViewController(),
            stemNumber: nil,
            stepImage: nil,
            state: .done
        )
    }

    static func emergencyKitIncomplete(state: ActionCardState) -> ActionCardModel {
        return ActionCardModel(
            title: NSAttributedString(string: L10n.SecurityCenter.s3),
            description: L10n.SecurityCenter.s4
                .attributedForDescription(),
            nextViewController: EmergencyKitSlidesViewController(),
            stemNumber: "3",
            stepImage: nil,
            state: state
        )
    }

    static func emergencyKitComplete() -> ActionCardModel {
        return ActionCardModel(
            title: NSAttributedString(string: L10n.SecurityCenter.s5),
            description: L10n.SecurityCenter.s6
                .attributedForDescription(),
            nextViewController: nil,
            stemNumber: nil,
            stepImage: nil,
            state: .done
        )
    }

}
