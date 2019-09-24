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
}

extension PartiallySignedTransaction {

    func sign(key: WalletPrivateKey, muunKey: WalletPublicKey) throws -> LibwalletTransaction {

        let partial = try doWithError({ error in
            LibwalletNewPartiallySignedTransaction(hexTransaction, error)
        })

        for input in inputs {
            partial.add(input)
        }

        return try partial.sign(key.key, muunKey: muunKey.key)
    }

    enum Errors: Error {
        case noMuunSignature
    }
}
