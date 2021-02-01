//
//  Recover+MoreInfo.swift
//  falcon
//
//  Created by Manu Herrera on 23/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

extension BottomDrawerInfo {

    static func whatIsTheRecoveryCodeSignIn(rcSetupDate: Date?) -> MoreInfo {
        let description: NSAttributedString

        if let setupDate = rcSetupDate {
            let dateText = setupDate.date()

            description = L10n.Recover.s3(dateText)
                .attributedForDescription()
                .set(bold: dateText, color: Asset.Colors.title.color)
        } else {
            description = L10n.Recover.s4.attributedForDescription()
        }

        return MoreInfo(title: L10n.Recover.s1,
                        description: description,
                        type: .whatIsTheRecoveryCode,
                        action: nil)
    }

    static func forgottenPassword(rcSetupDate: Date?) -> MoreInfo {
        let description: String
        if let setupDate = rcSetupDate {
            description = L10n.Recover.s5(setupDate.date())

        } else {
            description = L10n.Recover.s6
        }

        return MoreInfo(title: L10n.Recover.s2,
                        description: description.attributedForDescription(),
                        type: .forgotPassword,
                        action: nil)
    }

}
