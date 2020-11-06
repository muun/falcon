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

    struct SignedTransaction {
        let hash: String
        let bytes: Data
    }

    func sign(key: WalletPrivateKey, muunKey: WalletPublicKey, expectations: Expectations)
        throws -> SignedTransaction {

        let inputList = LibwalletInputList()
        for input in inputs {
            inputList.add(input)
        }

        let partial = try doWithError({ error in
            LibwalletNewPartiallySignedTransaction(inputList, Data(hex: hexTransaction), error)
        })

        let expectations = LibwalletNewSigningExpectations(
            expectations.destination,
            expectations.amount.value,
            expectations.change,
            expectations.fee.value)

        do {
            try partial.verify(expectations, userPublicKey: key.walletPublicKey().key, muunPublickKey: muunKey.key)
        } catch {
            Logger.log(error: error)
        }

        let signedTransaction = try partial.sign(key.key, muunKey: muunKey.key)

        return SignedTransaction(
            hash: signedTransaction.hash,
            bytes: signedTransaction.bytes!
        )
    }

    enum Errors: Error {
        case noMuunSignature
    }
}
