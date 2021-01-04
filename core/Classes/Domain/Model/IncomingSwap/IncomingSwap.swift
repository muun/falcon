//
//  IncomingSwap.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation

public struct IncomingSwap {
    let uuid: String
    public let paymentHash: Data
    let htlc: IncomingSwapHtlc?
    let sphinxPacket: Data?
    let collect: Satoshis
    let paymentAmountInSats: Satoshis
    public let preimage: Data?
}

public struct IncomingSwapHtlc {
    let uuid: String
    let expirationHeight: Int64
    let fulfillmentFeeSubsidyInSats: Satoshis
    let lentInSats: Satoshis
    let address: String
    let outputAmountInSatoshis: Satoshis
    let swapServerPublicKey: Data
    let htlcTx: Data
    // Present only if the swap is fulfilled
    let fulfillmentTx: Data?
}
