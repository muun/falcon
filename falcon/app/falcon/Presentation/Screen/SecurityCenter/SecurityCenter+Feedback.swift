//
//  SecurityCenter+Feedback.swift
//  falcon
//
//  Created by Manu Herrera on 23/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

extension FeedbackInfo {

    static func emailSetupSuccess(wording: SetUpEmailWording) -> FeedbackModel {
        return FeedbackModel(
            title: wording.successTitle(),
            description: wording.successDescription().attributedForDescription(),
            buttonText: L10n.SecurityCenter.s8,
            buttonAction: .popTo(vc: SecurityCenterViewController.self),
            image: Asset.Assets.success.image,
            lottieAnimationName: nil,
            loggingParameters: ["type": "email_setup_success"]
        )
    }

    static func recoveryCodeSetupSuccess(
        popTo vc: MUViewController.Type,
        wording: SetUpRecoveryCodeWording
    ) -> FeedbackModel {
        return FeedbackModel(
            title: wording.successTitle(),
            description: wording.successDescription().attributedForDescription(),
            buttonText: L10n.SecurityCenter.s8,
            buttonAction: .popTo(vc: vc),
            image: Asset.Assets.success.image,
            lottieAnimationName: nil,
            loggingParameters: ["type": "recovery_code_success"]
        )
    }

    static let recoveryCodeSetupFail = FeedbackModel(
        title: L10n.SecurityCenter.s9,
        description: L10n.SecurityCenter.s10.attributedForDescription(),
        buttonText: L10n.SecurityCenter.s11,
        buttonAction: .popToRoot,
        image: Asset.Assets.stateError.image,
        lottieAnimationName: nil,
        loggingParameters: ["type": "recovery_code_fail"]
    )

    static let emergencyKit = FeedbackModel(
        title: L10n.SecurityCenter.s12,
        description: L10n.SecurityCenter.ekSuccessDescription.attributedForDescription(),
        buttonText: L10n.SecurityCenter.s8,
        buttonAction: .popTo(vc: SecurityCenterViewController.self),
        image: Asset.Assets.success.image,
        lottieAnimationName: nil,
        loggingParameters: ["type": "emergency_kit_success"]
    )

}
