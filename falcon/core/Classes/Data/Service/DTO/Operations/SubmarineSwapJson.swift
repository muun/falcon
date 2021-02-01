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

    // This field is nil if the invoice doesn't specify an amount
    let fees: SubmarineSwapFeesJson?

    let expiresAt: Date
    let willPreOpenChannel: Bool

    let bestRouteFees: [BestRouteFeesJson]?
    let fundingOutputPolicies: FundingOutputPoliciesJson?

    let payedAt: Date?
    let preimageInHex: String?
}

struct BestRouteFeesJson: Codable {
    let maxCapacityInSat: Int64
    let proportionalMillionth: Int64
    let baseInSat: Int64
}

struct FundingOutputPoliciesJson: Codable {
    let maximumDebtInSat: Int64
    let potentialCollectInSat: Int64
    let maxAmountInSatFor0Conf: Int64
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
    // These two fields are nil if the invoice doesn't specify an amount
    let outputAmountInSatoshis: Int64?
    let confirmationsNeeded: Int?
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

    // These two fields are nil if the invoice doesn't specify an amount
    let debtType: String?
    let debtAmountInSats: Int64?
}

struct SubmarineSwapRequestJson: Codable {
    let invoice: String
    let swapExpirationInBlocks: Int
}
