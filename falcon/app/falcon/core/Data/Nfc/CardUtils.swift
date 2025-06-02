//
//  CardUtils.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

struct CardUtils {
    static func selectApplet(walletService: WalletService, appletId: String) {
        let length = appletId.count / 2
        let command = Data(hex: "00A404000\(length)\(appletId)")
        // swiftlint:disable force_error_handling
        guard let response = try? walletService.nfcTransmit(apduCommand: command)
            .toBlocking()
            .single()
        else { return }
        let statusCode = CardUtils.getNfcStatusCode(response.statusCode)
        Logger.log(.debug, "Selected AppletId with status: \(statusCode.rawValue)")
    }

    static func deselectApplet(walletService: WalletService) {
        // swiftlint:disable force_error_handling
        guard let response = try? walletService.nfcTransmit(apduCommand: Data(hex: "00A4040000"))
            .toBlocking()
            .single()
        else { return }
        let statusCode = CardUtils.getNfcStatusCode(response.statusCode)
        Logger.log(.debug, "Deselected AppletId with status:\(statusCode.rawValue)")
    }

    static func getNfcStatusCode(_ statusCode: Int) -> NfcStatusCode {
        switch statusCode {
        case NfcStatusCode.responseOk.rawValue:
            return NfcStatusCode.responseOk
        case NfcStatusCode.swMuunCardSlotOcuppied.rawValue:
            return NfcStatusCode.swMuunCardSlotOcuppied
        default:
            return NfcStatusCode.unknownError
        }
    }
}
