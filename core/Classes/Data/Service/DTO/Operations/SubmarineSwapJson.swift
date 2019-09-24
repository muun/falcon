//
//  SubmarineSwapJson.swift
//  falcon
//
//  Created by Manu Herrera on 03/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

struct SubmarineSwapJson: Codable {
    let swapUuid: String
    let invoice: String
    let receiver: SubmarineSwapReceiverJson
    let fundingOutput: SubmarineSwapFundingOutputJson

    let fees: SubmarineSwapFeesJson

    let expiresAt: Date
    let willPreOpenChannel: Bool

    let payedAt: Date?
    let preimageInHex: String?
}

struct SubmarineSwapFeesJson: Codable {
    let lightningInSats: Int64
    let sweepInSats: Int64
    let channelOpenInSats: Int64
    let channelCloseInSats: Int64
}

struct SubmarineSwapReceiverJson: Codable {
    let alias: String?
    let networkAddresses: [String]
    let publicKey: String?
}

struct SubmarineSwapFundingOutputJson: Codable {
    let outputAddress: String
    let outputAmountInSatoshis: Int64
    let confirmationsNeeded: Int
    let userLockTime: Int
    let userRefundAddress: MuunAddressJson
    let serverPaymentHashInHex: String
    let serverPublicKeyInHex: String
}
