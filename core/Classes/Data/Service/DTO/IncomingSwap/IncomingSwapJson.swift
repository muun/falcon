//
//  IncomingSwapJson.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 18/09/2020.
//

import Foundation

struct UserInvoiceJson: Codable {
    let paymentHashHex: String
    let shortChannelId: Int64
    let userPublicKey: PublicKeyJson
    let muunPublicKey: PublicKeyJson
    let identityPubKey: PublicKeyJson
}

struct ForwardingPolicyJson: Codable {
    let identityKeyHex: String
    let feeBaseMsat: Int64
    let feeProportionalMillionths: Int64
    let cltvExpiryDelta: Int64
}

public struct IncomingSwapJson: Codable {
    let uuid: String
    let paymentHashHex: String
    let htlc: IncomingSwapHtlcJson
    let sphinxPacketHex: String?
}

public struct IncomingSwapHtlcJson: Codable {
    let uuid: String
    let expirationHeight: Int64
    let paymentAmountInSats: Int64
    let fulfillmentFeeSubsidyInSats: Int64
    let lentInSats: Int64
    let address: String
    let outputAmountInSatoshis: Int64
    let swapServerPublicKeyHex: String
    let htlcTxHex: String
    // Present only if the swap is fulfilled
    let fulfillmentTxHex: String?
}
