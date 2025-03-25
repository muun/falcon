//
//  NewOp+MoreInfo.swift
//  falcon
//
//  Created by Manu Herrera on 23/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit


extension BottomDrawerInfo {

    static func newOpDestination(address: String) -> MoreInfo {
        return MoreInfo(title: L10n.NewOp.s1,
                        description: address.attributedForDescription(),
                        type: .newOpDestination,
                        action: nil)
    }

    static func swapDestination(pubKey: String, destinationInfo: NSAttributedString) -> MoreInfo {
        let title = L10n.NewOp.s2
        let onTap = {
            UIApplication.shared.open(URL(string: "\(Environment.current.nodeExplorer)\(pubKey)")!,
                                      options: [:],
                                      completionHandler: nil)
        }
        let action = MoreInfoAction(text: L10n.NewOp.s3, action: onTap)
        return MoreInfo(title: title,
                        description: destinationInfo,
                        type: .newOpDestination,
                        action: action)
    }

    static let oneConfNotice = MoreInfo(
        title: L10n.NewOp.s10,
        description: L10n.NewOp.s11.attributedForDescription(),
        type: .confsNeeded,
        action: nil
    )

    static let confsNeeded = MoreInfo(
        title: L10n.NewOp.s4,
        description: L10n.NewOp.s7.attributedForDescription(),
        type: .confsNeeded,
        action: nil
    )

    static let selectFee = MoreInfo(
        title: L10n.NewOp.s5,
        description: L10n.NewOp.s8.attributedForDescription(),
        type: .selectFee,
        action: nil
    )

    static let manualFee = MoreInfo(
        title: L10n.NewOp.s6,
        description: L10n.NewOp.s9.attributedForDescription(),
        type: .manualFee,
        action: nil
    )

}
