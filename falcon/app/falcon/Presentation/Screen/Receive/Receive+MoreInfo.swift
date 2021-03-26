//
//  Receive+MoreInfo.swift
//  falcon
//
//  Created by Manu Herrera on 23/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

extension BottomDrawerInfo {

    static func onChainAddress(_ address: String) -> MoreInfo {
        return MoreInfo(
            title: L10n.Receive.s1,
            description: address.attributedForDescription(),
            type: .onChainAddress,
            action: nil
        )
    }

    static func lightningInvoice(_ invoice: String) -> MoreInfo {
        return MoreInfo(
            title: L10n.Receive.s2,
            description: invoice.attributedForDescription(),
            type: .lightningInvoice,
            action: nil
        )
    }

    static let segwitLegacyInfo = MoreInfo(
        title: L10n.Receive.s3,
        description: L10n.Receive.s4.attributedForDescription(),
        type: .segwitLegacyInfo,
        action: nil
    )

}
