//
//  FulfillmentData.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation

struct IncomingSwapFulfillmentDataJson: Codable {
    let fulfillmentTxHex: String
    let muunSignatureHex: String
    let outputPath: String
    let outputVersion: Int
}
