//
//  FulfillmentData.swift
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation
import Libwallet

public struct IncomingSwapFulfillmentData {
    let fulfillmentTx: Data
    let muunSignature: Data
    let outputPath: String
    let outputVersion: Int

    func toLibwallet() -> LibwalletIncomingSwapFulfillmentData {
        let obj = LibwalletIncomingSwapFulfillmentData()
        obj.fulfillmentTx = fulfillmentTx
        obj.muunSignature = muunSignature
        obj.outputPath = outputPath
        obj.outputVersion = outputVersion

        // These are unused for now but should eventually be provided by houston
        obj.htlcBlock = Data()
        obj.confirmationTarget = 0
        obj.blockHeight = 0
        obj.merkleTree = Data()
        return obj
    }
}

public struct FulfillmentPushed {
    let nextTransactionSize: NextTransactionSize
    let feeBumpFunctions: FeeBumpFunctions
}
