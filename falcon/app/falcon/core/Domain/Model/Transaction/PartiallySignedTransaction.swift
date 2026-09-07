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
        let alternative: Bool
        let expectedDebtInSat: Satoshis

        func toAlternative() -> Expectations {
            return Expectations(
                destination: destination,
                amount: amount,
                fee: fee,
                change: change,
                alternative: true,
                expectedDebtInSat: expectedDebtInSat
            )
        }
    }

    struct SignedTransaction {
        let hash: String
        let bytes: Data
    }

    func sign(
        key: WalletPrivateKey,
        muunKey: WalletPublicKey,
        expectations: Expectations,
        nonces: LibwalletMusigNonces
    )
        throws -> SignedTransaction {

        let inputList = LibwalletInputList()
        for input in inputs {
            inputList.add(input)
        }

        let partial = try doWithError({ error in
            LibwalletNewPartiallySignedTransaction(
                inputList,
                Data(hex: hexTransaction),
                nonces,
                error
            )
        })

        let libwalletExpectations = LibwalletNewSigningExpectations(
            expectations.destination,
            expectations.amount.value,
            expectations.change,
            expectations.fee.value,
            expectations.alternative,
            expectations.expectedDebtInSat.value
        )

        let result = partial.verify(
            libwalletExpectations,
            userPublicKey: key.walletPublicKey().key,
            muunPublickKey: muunKey.key
        )

        guard let verification = result else {
            throw MuunError(Errors.verificationFailed(failedChecks: "noResult"))
        }

        if verification.mustNotSign() {
            Logger.log(.err, "PST verification failed: \(verification.summary())")
            throw MuunError(Errors.verificationFailed(failedChecks: verification.failedChecks()))
        }

        if verification.incubatingCheckFailed() {
            Logger.log(
                .err,
                "PST incubating checks failed: \(verification.summary()) "
                + "(expectedDebtInSat: \(expectations.expectedDebtInSat.value), "
                + "alternative: \(expectations.alternative))"
            )
            Logger.log(error: MuunError(
                Errors.incubatingCheckFailed(failedChecks: verification.failedChecks())
            ))
        }

        let signedTransaction = try partial.sign(key.key, muunKey: muunKey.key)

        return SignedTransaction(
            hash: signedTransaction.hash,
            bytes: signedTransaction.bytes!
        )
    }

    enum Errors: Error {
        case noMuunSignature
        case verificationFailed(failedChecks: String)
        case incubatingCheckFailed(failedChecks: String)
    }
}

extension PartiallySignedTransaction.Errors: ClassifiedError {
    var classification: ErrorClassification {
        switch self {
        case .noMuunSignature, .verificationFailed, .incubatingCheckFailed:
            return .unexpected
        }
    }
}
