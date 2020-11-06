//
//  IncomingSwap.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation

public struct IncomingSwap {
    let uuid: String
    let paymentHash: Data
    let htlc: IncomingSwapHtlc
    let sphinxPacket: Data?
}

public struct IncomingSwapHtlc {
    let uuid: String
    let expirationHeight: Int64
    let paymentAmountInSats: Satoshis
    let fulfillmentFeeSubsidyInSats: Satoshis
    let lentInSats: Satoshis
    let address: String
    let outputAmountInSatoshis: Satoshis
    let swapServerPublicKey: Data
    let htlcTx: Data
    // Present only if the swap is fulfilled
    let fulfillmentTx: Data?
}
