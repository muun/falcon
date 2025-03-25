//
//  TransactionSchemeV2Tests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 18/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

@testable import Muun
import Libwallet

class TransactionSchemeV2Tests: XCTestCase {

    let json = """
{"hexTransaction":"010000000133f1f8fac47ab08184d6826fbe94a61afeb05237870de204d904ea76cfe6962e0000000000ffffffff02b0069a3b0000000017a914aee5042479b615875d0bb3e29e5ef57101d7c32d87a86100000000000017a914d827c17150f6976ae1807b2d99de7b4ddab6b3f88700000000","inputs":[{"prevOut":{"txId":"2e96e6cf76ea04d904e20d873752b0fe1aa694be6f82d68481b07ac4faf8f133","index":0,"amount":1000000000},"address":{"version":2,"derivationPath":"m/schema:1'/recovery:1'/external:1/0","address":"2NCTw5q4SuHaJt47gihEmvvnzUcTJdxyDe6"},"muunSignature":{"hex":"3045022100b8ee81071f9c677ffcbb6dec7a2324dfb0ae168696b5ab0c829a127d02c3ee6b02202e691421f23b64348d03116e670897b4bd55dfd1e6e0a403528e2bb6d06dd5a701"}}]}
""".data(using: .utf8)!

    func testSign() throws {

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .customISO8601
        let partiallySigned = try jsonDecoder.decode(PartiallySignedTransactionJson.self, from: json).toModel()

        let muunKey = WalletPublicKey.fromBase58("tpubDBZaivUL3Hv8r25JDupShPuWVkGcwM7NgbMBwkhQLfWu18iBbyQCbRdyg1wRMjoWdZN7Afg3F25zs4c8E6Q4VJrGqAw51DJeqacTFABV9u8", on: "m/schema:1'/recovery:1'")

        let privateKey = WalletPrivateKey.fromBase58("tprv8f8dgxCNT9QD3coYhy1pPrQJiyLmKNcyNbatb5zWYRjhL5ctu4UhmsRawtAqxmuiDciuuLj98P72QNfCzMqEWf38EgCEj3RK6QSsHG2aK24", on: "m/schema:1'/recovery:1'")

        // expectactions are kinda ignored right now
        _ = try partiallySigned.sign(
            key: privateKey,
            muunKey: muunKey,
            expectations: PartiallySignedTransaction.Expectations(
                destination: "2N9Byuz8A5CBHMjJAisG6BVaG6D3TQAVkK7",
                amount: Satoshis.from(bitcoin: 9.9995),
                fee: Satoshis(value: 0),
                change: nil,
                alternative: false
            ),
            nonces: LibwalletGenerateMusigNonces(1)!
        )
    }

}
