//
//  Transaction.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public struct Transaction {
    public var hash: String?
    public var confirmations: Int
    public var isReplaceableByFee: Bool
}

public struct NextTransactionSize: Codable {
    let sizeProgression: [SizeForAmount]
    let validAtOperationHid: Double?
    let _expectedDebt: Satoshis?

    var expectedDebt: Satoshis {
        guard let debt = _expectedDebt else {
            return Satoshis(value: 0)
        }

        if debt.asDecimal() < 0 {
            // We can't allow negative debt
            Logger.log(.warn, "Negative debt: \(debt.asDecimal())")
            return Satoshis(value: 0)
        }

        return debt
    }

    // UI Balance is calculated by substracting the debt from the last item in the next transaction size.
    func uiBalance() -> Satoshis {
        guard let utxoBalanceInSat = sizeProgression.last?.amountInSatoshis else {
            // If the user does not have any utxo the balance should be 0
            return Satoshis(value: 0)
        }

        return utxoBalanceInSat - expectedDebt
    }
}

public struct SizeForAmount: Codable {
    let amountInSatoshis: Satoshis
    // The sizeInBytes actually returns the size in WeightUnit, we need to divide that number by 4 to have vBytes
    let sizeInBytes: Int64

    // This property can't be nullable in versions > 46
    let outpoint: String?
}

struct RawTransaction {
    let hex: String
}

struct RawTransactionResponse {
    let hex: String?
    let nextTransactionSize: NextTransactionSize
    let updatedOperation: Operation
}
