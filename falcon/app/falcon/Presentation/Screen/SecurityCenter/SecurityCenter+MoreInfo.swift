//
//  SecurityCenter+MoreInfo.swift
//  falcon
//
//  Created by Manu Herrera on 23/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

extension BottomDrawerInfo {

    static let signUpPassword = MoreInfo(
        title: L10n.SecurityCenter.s13,
        description: L10n.SecurityCenter.s17
            .attributedForDescription(),
        type: .password,
        action: nil
    )

    static let whatIsTheRecoveryCode = MoreInfo(
        title: L10n.SecurityCenter.s14,
        description: L10n.SecurityCenter.s18
            .attributedForDescription()
            .set(bold: L10n.SecurityCenter.s15, color: Asset.Colors.title.color),
        type: .whatIsTheRecoveryCode,
        action: nil
    )

    static let whyEmail = MoreInfo(
        title: L10n.SecurityCenter.s16,
        description: L10n.SecurityCenter.s19
            .attributedForDescription(),
        type: .whyEmail,
        action: nil
    )

    static let cloudStorage = MoreInfo(
        title: L10n.SecurityCenter.s20,
        description: L10n.SecurityCenter.s21
            .attributedForDescription(),
        type: .cloudStorage,
        action: nil
    )

}
