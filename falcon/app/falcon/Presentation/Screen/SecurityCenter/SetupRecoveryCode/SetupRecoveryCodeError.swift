//
//  SetupRecoveryCodeError.swift
//  Muun
//
//  Created by Lucas Serruya on 26/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation


enum SetupRecoveryCodeError: ErrorViewModel {
    case failedToStartSetup
    case failedToFinishSetup

    func title() -> String {
        switch self {
        case .failedToStartSetup: return L10n.RecoveryCodePrimingViewController.s2
        case .failedToFinishSetup: return L10n.FinishRecoveryCodeSetupViewController.s3
        }
    }

    func description() -> NSAttributedString {
        switch self {
        case .failedToStartSetup:
            return L10n.RecoveryCodePrimingViewController.s3
                .attributedForDescription(alignment: .center)
        case .failedToFinishSetup:
            return L10n.FinishRecoveryCodeSetupViewController.s4
                .attributedForDescription(alignment: .center)
        }
    }

    func kind() -> ErrorViewKind {
        return .retryable
    }

    func loggingName() -> String {
        switch self {
        case .failedToStartSetup:
            return "rc_setup_start_connection_error"
        case .failedToFinishSetup:
            return "rc_setup_finish_connection_error"
        }
    }

    func secondaryButtonText() -> String {
        return L10n.ErrorView.goToSecurityCenter
    }
}
