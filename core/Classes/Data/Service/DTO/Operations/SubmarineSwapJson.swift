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
    let scriptVersion: Int
    let outputAddress: String
    let outputAmountInSatoshis: Int64
    let confirmationsNeeded: Int
    // This field is available once the funding has 1 conf
    let userLockTime: Int?
    let serverPaymentHashInHex: String
    let serverPublicKeyInHex: String
    let expirationInBlocks: Int?

    // v1 only
    let userRefundAddress: MuunAddressJson?

    // v2 only
    let userPublicKey: PublicKeyJson?
    let muunPublicKey: PublicKeyJson?

    let debtType: String
    let debtAmountInSats: Int64
}

struct SubmarineSwapRequestJson: Codable {
    let invoice: String
    let swapExpirationInBlocks: Int
}
