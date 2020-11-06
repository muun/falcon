//
//  ForwardingPolicy.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 18/09/2020.
//

import Foundation

struct ForwardingPolicy: Codable {
    let identityKeyHex: String
    let feeBaseMsat: Int64
    let feeProportionalMillionths: Int64
    let cltvExpiryDelta: Int64
}
