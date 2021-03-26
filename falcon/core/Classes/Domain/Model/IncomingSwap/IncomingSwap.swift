//
//  IncomingSwap.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation
import Libwallet

public class IncomingSwap {
    let uuid: String
    public let paymentHash: Data
    let htlc: IncomingSwapHtlc?
    let sphinxPacket: Data?
    let collect: Satoshis
    let paymentAmountInSats: Satoshis
    public private(set) var preimage: Data?

    public init(uuid: String, paymentHash: Data, htlc: IncomingSwapHtlc?, sphinxPacket: Data?,
                collect: Satoshis, paymentAmountInSats: Satoshis, preimage: Data?) {
        self.uuid = uuid
        self.paymentHash = paymentHash
        self.htlc = htlc
        self.sphinxPacket = sphinxPacket
        self.collect = collect
        self.paymentAmountInSats = paymentAmountInSats
        self.preimage = preimage
    }

    private func toLibwallet() -> LibwalletIncomingSwap {
        let obj = LibwalletIncomingSwap()
        obj.htlc = htlc?.toLibwallet()
        obj.sphinxPacket = sphinxPacket
        obj.paymentHash = paymentHash
        obj.paymentAmountSat = paymentAmountInSats.value
        obj.collectSat = collect.value
        return obj
    }

    func verifyFulfillable(userKey: WalletPrivateKey) throws {
        return try toLibwallet().verifyFulfillable(userKey.key, net: Environment.current.network)
    }

    func fulfill(_ data: IncomingSwapFulfillmentData,
                 userKey: WalletPrivateKey,
                 muunKey: WalletPublicKey) throws -> IncomingSwapFulfillmentResult {

        let result = try toLibwallet().fulfill(
            data.toLibwallet(),
            userKey: userKey.key,
            muunKey: muunKey.key,
            net: Environment.current.network
        )

        preimage = result.preimage

        return IncomingSwapFulfillmentResult(
            fullfillmentTx: result.fulfillmentTx!,
            preimage: result.preimage!
        )
    }

    func fulfillFullDebt() throws -> Data {
        let result = try toLibwallet().fulfillFullDebt()
        preimage = result.preimage
        return result.preimage!
    }
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

    fileprivate func toLibwallet() -> LibwalletIncomingSwapHtlc {
        let obj = LibwalletIncomingSwapHtlc()
        obj.expirationHeight = expirationHeight
        obj.swapServerPublicKey = swapServerPublicKey
        obj.htlcTx = htlcTx
        return obj
    }
}

public struct IncomingSwapFulfillmentResult {
    let fullfillmentTx: Data
    let preimage: Data
}
