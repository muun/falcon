//
//  FulfillincomingSwapActionTest.swift
//
//  Created by Juan Pablo Civile on 25/01/2021.
//

import XCTest
import RxSwift
import Libwallet
import CryptoKit
@testable import Muun

class FulfillIncomingSwapActionTest: MuunTestCase {

    fileprivate var incomingSwapRepository: IncomingSwapRepository!
    fileprivate var operationRepository: OperationRepository!

    fileprivate var fakeHoustonService: FakeHoustonService!
    fileprivate var fakeKeysRepository: FakeKeysRepository!

    fileprivate var userKey: WalletPrivateKey = {
        return try! WalletPrivateKey.createRandom().derive(to: .base)
    }()

    fileprivate var muunKey: WalletPrivateKey = {
        return try! WalletPrivateKey.createRandom().derive(to: .base)
    }()

    fileprivate var action: FulfillIncomingSwapAction!


    override func setUp() {
        super.setUp()

        fakeHoustonService = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        fakeKeysRepository = replace(.singleton, KeysRepository.self, FakeKeysRepository.init)
        fakeKeysRepository.userKey = userKey
        fakeKeysRepository.muunKey = muunKey

        incomingSwapRepository = resolve()
        operationRepository = resolve()
        action = resolve()
    }

    func testNoSwap() {
        expectError(for: action.run(uuid: "fruta")) { error in
            return error.contains(FulfillIncomingSwapAction.Errors.unknownSwap)
        }
    }

    func testNoInvoiceForSwap() {
        let op = Factory.incomingSwapOperation(status: .BROADCASTED)
        wait(for: operationRepository.storeOperations([op]))

        wait(for: action.run(uuid: op.incomingSwap!.uuid))

        XCTAssertEqual(fakeHoustonService.fetchFulfillmentCalls, 0)
        XCTAssertEqual(fakeHoustonService.expiredCalls, 1)
        XCTAssertEqual(fakeHoustonService.expiredHash[0], op.incomingSwap!.paymentHash)
    }

    func testOnChainAlreadyFulfilled() {

        let invoices = try! doWithError { err in
            LibwalletGenerateInvoiceSecrets(userKey.walletPublicKey().key, muunKey.walletPublicKey().key, err)
        }
        _ = try! doWithError({ error in
            LibwalletPersistInvoiceSecrets(invoices, error)
        })

        let invoice = invoices.get(0)!
        let swap = Factory.incomingSwap(paymentHash: invoice.paymentHash!, amount: Satoshis(value: 1000))
        let op = Factory.incomingSwapOperation(status: .BROADCASTED, incomingSwap: swap)

        wait(for: operationRepository.storeOperations([op]))

        wait(for: action.run(uuid: swap.uuid))

        XCTAssertEqual(fakeHoustonService.fetchFulfillmentCalls, 1)
    }

    @available(iOS 13, *)
    func testFulfillFullDebt() {
        let invoices = try! doWithError { err in
            LibwalletGenerateInvoiceSecrets(userKey.walletPublicKey().key, muunKey.walletPublicKey().key, err)
        }
        _ = try! doWithError({ error in
            LibwalletPersistInvoiceSecrets(invoices, error)
        })

        let invoice = invoices.get(0)!
        let swap = Factory.incomingSwapFullDebt(paymentHash: invoice.paymentHash!, amount: Satoshis(value: 1000))
        let op = Factory.incomingSwapOperation(status: .BROADCASTED, incomingSwap: swap)

        wait(for: operationRepository.storeOperations([op]))

        wait(for: action.run(uuid: swap.uuid))

        XCTAssertEqual(fakeHoustonService.fetchFulfillmentCalls, 0)
        XCTAssertEqual(fakeHoustonService.fulfillCalls, 1)
        let preimage = try! XCTUnwrap(fakeHoustonService.pushedPreimage[0])

        XCTAssertTrue(SHA256.hash(data: preimage).elementsEqual(invoice.paymentHash!))
    }

    func testUnfulfillable() {
        // We use a malformed sphinx to cause libwallet to consider it unfulfillable

        let invoices = try! doWithError { err in
            LibwalletGenerateInvoiceSecrets(userKey.walletPublicKey().key, muunKey.walletPublicKey().key, err)
        }
        _ = try! doWithError({ error in
            LibwalletPersistInvoiceSecrets(invoices, error)
        })

        let invoice = invoices.get(0)!
        let swap = Factory.incomingSwap(paymentHash: invoice.paymentHash!,
                                        amount: Satoshis(value: 1000),
                                        sphinxPacket: "hola".data(using: .utf8)!)
        let op = Factory.incomingSwapOperation(status: .BROADCASTED, incomingSwap: swap)

        wait(for: operationRepository.storeOperations([op]))

        wait(for: action.run(uuid: swap.uuid))

        XCTAssertEqual(fakeHoustonService.fetchFulfillmentCalls, 0)
        XCTAssertEqual(fakeHoustonService.expiredCalls, 1)
        XCTAssertEqual(fakeHoustonService.expiredHash[0], swap.paymentHash)
    }
}
