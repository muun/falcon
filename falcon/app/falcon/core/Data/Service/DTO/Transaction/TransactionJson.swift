//
//  Transaction.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct TransactionJson: Codable {
    let hash: String?
    let confirmations: Int
    let isReplaceableByFee: Bool
}

struct PartiallySignedTransactionJson: Codable {
    let hexTransaction: String
    let inputs: [MuunInputJson]
}

struct SignatureJson: Codable {
    let hex: String
}

struct NextTransactionSizeJson: Codable {
    let sizeProgression: [SizeForAmountJson]
    let validAtOperationHid: Double?
    let expectedDebtInSat: Int64
}

struct SizeForAmountJson: Codable {
    let amountInSatoshis: Int64
    // The sizeInBytes actually returns the size in WeightUnit, we need to divide that number by 4 to have vBytes
    let sizeInBytes: Int64
    let outpoint: String
    let status: UtxoStatusJson
}

public enum UtxoStatusJson: String, Codable {
    case UNCONFIRMED
    case CONFIRMED
}

struct RawTransactionJson: Codable {
    let hex: String
}

struct RawTransactionResponseJson: Codable {
    let hex: String?
    let nextTransactionSize: NextTransactionSizeJson
    let updatedOperation: OperationJson
    let feeBumpFunctions: FeeBumpFunctionsJson
}
