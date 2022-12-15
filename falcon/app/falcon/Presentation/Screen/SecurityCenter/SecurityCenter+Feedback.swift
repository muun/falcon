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

    static let emergencyKit = FeedbackModel(
        title: L10n.SecurityCenter.s12,
        description: L10n.SecurityCenter.ekSuccessDescription.attributedForDescription(),
        buttonText: L10n.SecurityCenter.s8,
        buttonAction: .popTo(vc: SecurityCenterViewController.self),
        image: Asset.Assets.success.image,
        lottieAnimationName: nil,
        loggingParameters: ["type": "emergency_kit_success"]
    )

    static func taprootPreactived(blocksLeft: UInt) -> FeedbackModel {

        // Exported asset is cut to the border of the image, but we need to align it differently
        let image = Asset.Assets.taprootPreactivated.image
            .withInsets(UIEdgeInsets(top: 0, left: 0, bottom: .closeSpacing, right: 0))

        return FeedbackModel(
            title: L10n.SecurityCenter.TaprootActivated.title,
            description: L10n.SecurityCenter.TaprootPreactivated.description(
                blocksLeft, BlockHelper.hoursFor(blocksLeft)
            ).attributedForDescription(),
            buttonText: L10n.SecurityCenter.s8,
            buttonAction: .popToRoot,
            image: image,
            lottieAnimationName: nil,
            loggingParameters: ["type": "taproot_preactivation_success"],
            blocksLeft: blocksLeft
        )
    }

    static let taprootActive = FeedbackModel(
        title: L10n.SecurityCenter.TaprootActivated.title,
        description: L10n.SecurityCenter.TaprootActivated.description.attributedForDescription(),
        buttonText: L10n.SecurityCenter.s8,
        buttonAction: .popToRoot,
        image: Asset.Assets.taprootActivated.image,
        lottieAnimationName: nil,
        loggingParameters: ["type": "taproot_activation_success"]
    )

    static func taprootPreactivationCountdown(blocksLeft: UInt) -> FeedbackModel {
        FeedbackModel(
            title: L10n.SecurityCenter.TaprootActivationCountdown.title,
            description: L10n.SecurityCenter.TaprootActivationCountdown.description(6, blocksLeft)
                .attributedForDescription(),
            buttonText: nil,
            buttonAction: nil,
            image: Asset.Assets.taprootCountdown.image,
            lottieAnimationName: nil,
            loggingParameters: ["type": "taproot_preactivation_countdown"],
            blocksLeft: blocksLeft
        )
    }

}
