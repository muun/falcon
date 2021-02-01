//
//  FulfillmentData.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation

struct IncomingSwapFulfillmentData {
    let fulfillmentTx: Data
    let muunSignature: Data
    let outputPath: String
    let outputVersion: Int
}
