//
//  Home+ActionCard.swift
//  falcon
//
//  Created by Manu Herrera on 22/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

extension ActionCardModel {

    static func homeBackUp() -> ActionCardModel {
        return ActionCardModel(
            title: L10n.Home.backUp
                .set(font: Constant.Fonts.system(size: .opHelper, weight: .medium),
                     lineSpacing: Constant.FontAttributes.lineSpacing)
                .set(tint: L10n.Home.boldBackUp, color: Asset.Colors.muunBlue.color),
            description: "".attributedForDescription(),
            nextViewController: SecurityCenterViewController(origin: .emptyAnonUser),
            stemNumber: nil,
            stepImage: Asset.Assets.actionCardBackUp.image,
            state: .home,
            accessibilityLabel: L10n.Home.backUp
        )
    }

    static func activateTaproot() -> ActionCardModel {
        return ActionCardModel(
            title: L10n.Home.activateTaproot
                .set(font: Constant.Fonts.system(size: .opHelper, weight: .medium),
                     lineSpacing: Constant.FontAttributes.lineSpacing)
                .set(tint: L10n.Home.activateTaprootHighlight, color: Asset.Colors.muunBlue.color),
            description: "".attributedForDescription(),
            nextViewController: UIViewController(), // Any controller sufices here. This should be refactored.
            stemNumber: nil,
            stepImage: Asset.Assets.levelUp.image,
            state: .home,
            accessibilityLabel: nil
        )
    }

    static func highFeesHomeBanner() -> ActionCardModel {
        return ActionCardModel(
            title: L10n.Home.highFeesBannerTitle
                .set(font: Constant.Fonts.system(size: .opHelper, weight: .medium),
                     lineSpacing: Constant.FontAttributes.lineSpacing),
            description: "".attributedForDescription(),
            nextViewController: UIViewController(), // Any controller sufices here. This should be refactored.
            stemNumber: nil,
            stepImage: Asset.Assets.notice.image,
            state: .home,
            accessibilityLabel: L10n.Home.highFeesBannerTitle,
            accessibilityTrait: .staticText
        )
    }

    static func iOSUnder15Banner() -> ActionCardModel {
        return ActionCardModel(
            title: L10n.Home.iosUnder15Banner
                .set(font: Constant.Fonts.system(size: .opHelper, weight: .medium),
                     lineSpacing: Constant.FontAttributes.lineSpacing),
            description: "".attributedForDescription(),
            nextViewController: UIViewController(), // Any controller sufices here.
            stemNumber: nil,
            stepImage: Asset.Assets.notice.image,
            state: .home,
            accessibilityLabel: L10n.Home.highFeesBannerTitle,
            accessibilityTrait: .staticText
        )
    }

}
