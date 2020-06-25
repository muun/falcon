//
//  PartiallySignedTransaction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 18/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

struct PartiallySignedTransaction {
    let hexTransaction: String
    let inputs: [MuunInput]

    struct Expectations {
        let destination: String
        let amount: Satoshis
        let fee: Satoshis
        let change: MuunAddress?
    }
}

extension PartiallySignedTransaction {

    func sign(key: WalletPrivateKey, muunKey: WalletPublicKey, expectations: Expectations)
        throws -> LibwalletTransaction {

        let partial = try doWithError({ error in
            LibwalletNewPartiallySignedTransaction(hexTransaction, error)
        })

        for input in inputs {
            partial.add(input)
        }

        partial.expectations = LibwalletNewSigningExpectations(
            expectations.destination,
            expectations.amount.value,
            expectations.change,
            expectations.fee.value)

        do {
            try partial.verify(key.walletPublicKey().key, muunPublickKey: muunKey.key)
        } catch {
            Logger.log(error: error)
        }

        return try partial.sign(key.key, muunKey: muunKey.key)
    }

    enum Errors: Error {
        case noMuunSignature
    }
}
