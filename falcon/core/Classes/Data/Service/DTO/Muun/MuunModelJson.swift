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
    let submarineSwap: InputSubmarineSwapV1Json?
    let submarineSwapV102: InputSubmarineSwapV2Json?
    let incomingSwap: InputIncomingSwapJson?
    let rawMuunPublicNonceHex: String?
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

struct InputSubmarineSwapV1Json: Codable {
    let refundAddress: String
    let swapPaymentHash256Hex: String
    let swapServerPublicKeyHex: String
    let lockTime: Int64
}

struct InputSubmarineSwapV2Json: Codable {
    let swapPaymentHash256Hex: String

    let userPublicKeyHex: String
    let muunPublicKeyHex: String
    let swapServerPublicKeyHex: String

    let numBlocksForExpiration: Int
    let swapServerSignature: SignatureJson?
}

struct InputIncomingSwapJson: Codable {
    let sphinxHex: String
    let htlcTxHex: String
    let swapServerPublicKeyHex: String
    let paymentHash256Hex: String
    let expirationHeight: Int64
    let collectInSats: Int64
}
