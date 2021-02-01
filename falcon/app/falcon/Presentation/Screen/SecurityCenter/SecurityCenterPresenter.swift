//
//  SecurityCenterPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 20/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import core

protocol SecurityCenterPresenterDelegate: BasePresenterDelegate {}

class SecurityCenterPresenter<Delegate: SecurityCenterPresenterDelegate>: BasePresenter<Delegate> {

    private let sessionActions: SessionActions

    init(delegate: Delegate, sessionActions: SessionActions) {
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    func getEmailCard() -> ActionCardModel {
        let hasRc = sessionActions.hasRecoveryCode()
        let wording: SetUpEmailWording = hasRc ? .recoveryCodeSetup : .recoveryCodeNotSetup

        // If the user has email set up -> Card = complete
        if hasEmailAndPassword(), let email = sessionActions.getUserEmail() {
            return ActionCard.emailComplete(wording: wording, email: email)
        }

        // Without email setup we can have it skipped or active:

        // Skipped
        if sessionActions.isEmailSkipped() {
            // And it can have the RC set up or not
            return ActionCard.emailIncomplete(wording: wording, state: .skipped)
        }

        // Active
        return ActionCard.emailIncomplete(wording: .recoveryCodeNotSetup, state: .active)
    }

    func getRecoveryCodeCard() -> ActionCardModel {
        // If the user has recovery code set up -> Card = complete
        if sessionActions.hasRecoveryCode() {
            let wording: SetUpRecoveryCodeWording = hasEmailAndPassword() ? .emailSetup : .emailNotSetup
            if let email = sessionActions.getUserEmail() {
                return ActionCard.recoveryCodeComplete(wording: wording, email: email)
            }

            return ActionCard.recoveryCodeComplete(wording: wording)
        }

        // Without recovery code set up we can be in one of these states:

        if hasEmailAndPassword() {
            // 1. active with email set up
            return ActionCard.recoveryCodeIncomplete(wording: .emailSetup, state: .active, emailSkipped: false)
        }

        if sessionActions.isEmailSkipped() {
            // 2. active with email skipped
            return ActionCard.recoveryCodeIncomplete(wording: .emailNotSetup, state: .active, emailSkipped: true)
        }

        // 3. inactive
        return ActionCard.recoveryCodeIncomplete(wording: .emailNotSetup, state: .inactive, emailSkipped: false)
    }

    func getEmergencyKitCard() -> ActionCardModel {
        // 1. User exported emergency kit
        if didExportEmergencyKit() {
            return ActionCard.emergencyKitComplete()
        }

        // 2. User exported private keys (deprecated flow)
        if didExportPrivateKeys() {
            return ActionCard.exportKeysComplete()
        }

        // 3. User doesn't have RC setup -> Card = inactive
        if !sessionActions.hasRecoveryCode() {
            return ActionCard.emergencyKitIncomplete(state: .inactive)
        }

        // 4. User does have recovery code setup -> Card = active
        return ActionCard.emergencyKitIncomplete(state: .active)
    }

    private func hasRecoveryCode() -> Bool {
        return sessionActions.hasRecoveryCode()
    }

    private func hasEmailAndPassword() -> Bool {
        return sessionActions.hasPasswordChallengeKey()
    }

    private func didExportPrivateKeys() -> Bool {
        return sessionActions.hasExportedKeys()
    }

    func didExportEmergencyKit() -> Bool {
        return sessionActions.hasExportedEmergencyKit()
    }

    func isBackUpProgressStarted() -> Bool {
        // Returns if the user has completed at least one step of the back up
        return hasRecoveryCode() || hasEmailAndPassword()
    }

    func isBackUpProgressFinished() -> Bool {
        // Returns if the user has completed the last step of the back up
        return didExportEmergencyKit() || didExportPrivateKeys()
    }

    func backUpProgressMultiplier() -> CGFloat {
        // Returns the multiplier for the progress bar
        if !isBackUpProgressStarted() {
            return 0.1
        }

        if isBackUpProgressFinished() {
            return 1
        }

        if hasEmailAndPassword() && hasRecoveryCode() {
            return 0.8
        }

        // Here the user either has RC or email, but not both
        return 0.5
    }

    func backUpProgressMessage() -> String {
        // Returns the message to display below the progress bar
        if !isBackUpProgressStarted() {
            return L10n.SecurityCenterPresenter.s1
        }

        if isBackUpProgressFinished() {
            return "" // No message needed here
        }

        // If the user hasRecoveryCode, we display this message no matter what the email status is
        if hasRecoveryCode() {
            return L10n.SecurityCenterPresenter.s2
        }

        if hasEmailAndPassword() && !hasRecoveryCode() {
            // Even though the second condition is redundant, it adds clarity
            return L10n.SecurityCenterPresenter.s3
        }

        return "" // There is no way to reach this point
    }

    func nextStepLogParam() -> String {
        if !isBackUpProgressStarted() {
            return "set_up_email"
        }

        if isBackUpProgressFinished() {
            return "fully_set"
        }

        if hasRecoveryCode() {
            return "emergency_kit"
        }

        return "set_up_recovery_code"
    }

    func emailStatusLogParam() -> String {
        if hasEmailAndPassword() {
            return "completed"
        }

        if sessionActions.isEmailSkipped() {
            return "skipped"
        }

        return "not_set"
    }

}
