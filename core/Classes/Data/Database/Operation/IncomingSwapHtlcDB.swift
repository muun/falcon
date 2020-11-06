//
//  IncomingSwapHtlcDB.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation
import GRDB

struct IncomingSwapHtlcDB: Codable, FetchableRecord, PersistableRecord {

    typealias PrimaryKeyType = String

    let uuid: String
    let incomingSwapUuid: String
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

extension IncomingSwapHtlcDB {

    init(from: IncomingSwapHtlc, swap: IncomingSwap) {
        self.uuid = from.uuid
        self.incomingSwapUuid = swap.uuid
        self.expirationHeight = from.expirationHeight
        self.paymentAmountInSats = from.paymentAmountInSats.value
        self.fulfillmentFeeSubsidyInSats = from.fulfillmentFeeSubsidyInSats.value
        self.lentInSats = from.lentInSats.value
        self.address = from.address
        self.outputAmountInSatoshis = from.outputAmountInSatoshis.value
        self.swapServerPublicKeyHex = from.swapServerPublicKey.toHexString()
        self.htlcTxHex = from.htlcTx.toHexString()
        self.fulfillmentTxHex = from.fulfillmentTx?.toHexString()
    }

    func to(using db: Database) throws -> IncomingSwapHtlc {
        return IncomingSwapHtlc(
            uuid: uuid,
            expirationHeight: expirationHeight,
            paymentAmountInSats: Satoshis(value: paymentAmountInSats),
            fulfillmentFeeSubsidyInSats: Satoshis(value: fulfillmentFeeSubsidyInSats),
            lentInSats: Satoshis(value: lentInSats),
            address: address,
            outputAmountInSatoshis: Satoshis(value: outputAmountInSatoshis),
            swapServerPublicKey: Data(hex: swapServerPublicKeyHex),
            htlcTx: Data(hex: htlcTxHex),
            fulfillmentTx: fulfillmentTxHex.map(Data.init(hex:))
        )
    }

}
