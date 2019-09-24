//
//  MuunModel.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct MuunInputJson: Codable {
    let prevOut: MuunOutputJson
    let address: MuunAddressJson
    let userSignature: SignatureJson?
    let muunSignature: SignatureJson?
    let submarineSwap: InputSubmarineSwapJson?
}

struct MuunOutputJson: Codable {
    let txId: String
    let index: Int
    let amount: Double
}

struct MuunAddressJson: Codable {
    let version: Int
    let derivationPath: String
    let address: String
}

struct InputSubmarineSwapJson: Codable {
    let refundAddress: String
    let swapPaymentHash256Hex: String
    let swapServerPublicKeyHex: String
    let lockTime: Int64
}
