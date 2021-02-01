//
//  Settings+Feedback.swift
//  falcon
//
//  Created by Manu Herrera on 25/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

extension FeedbackInfo {

    static let deleteWallet = FeedbackModel(
        title: L10n.Settings.s1,
        description: L10n.Settings.s5
            .attributedForDescription()
            .set(underline: L10n.Settings.s4, color: Asset.Colors.muunBlue.color),
        buttonText: L10n.Settings.s2,
        buttonAction: .resetToGetStarted,
        image: Asset.Assets.success.image,
        lottieAnimationName: nil,
        loggingParameters: ["type": "delete_wallet"]
    )

    static let changePassword = FeedbackModel(
        title: L10n.Settings.s3,
        description: "".attributedForDescription(),
        buttonText: L10n.Settings.s2,
        buttonAction: .popTo(vc: SettingsViewController.self),
        image: Asset.Assets.success.image,
        lottieAnimationName: nil,
        loggingParameters: ["type": "change_password"]
    )

}
