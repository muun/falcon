//
//  CreateBitcoinuriAction.swift
//  core-all
//
//  Created by Lucas Serruya on 23/11/2022.
//

import Foundation
import Libwallet
import RxSwift

public struct ReusableInvoiceForURICreation {
    fileprivate let raw: String
    fileprivate let expiresAt: Double?

    public init(raw: String, expiresAt: Double?) {
        self.raw = raw
        self.expiresAt = expiresAt
    }

    fileprivate func isNotExpired() -> Bool {
        return expirationTimeInSeconds ?? 0 >= 1
    }

    private var expirationTimeInSeconds: Int? {
        guard let expiresAt = expiresAt else {
            return nil
        }
        return Int(expiresAt - Date().timeIntervalSince1970)
    }
}

public class CreateBitcoinURIAction {

    let createInvoiceAction: CreateInvoiceAction

    init(createInvoiceAction: CreateInvoiceAction) {
        self.createInvoiceAction = createInvoiceAction
    }

    public func run(amount: Satoshis?,
                    reusableInvoice: ReusableInvoiceForURICreation?,
                    address: String) -> Single<RawBitcoinURI> {
        guard let reusableInvoice = reusableInvoice, reusableInvoice.isNotExpired() else {
            return createInvoiceAction.run(amount: amount).flatMap { invoice in
                self.generateURI(amount: amount, address: address, invoice: invoice)
            }
        }

        return generateURI(amount: amount, address: address, invoice: reusableInvoice.raw)
    }

    private func generateURI(amount: Satoshis?, address: String, invoice: String) -> Single<RawBitcoinURI> {
        Single.deferred {
            let paymentURI = LibwalletMuunPaymentURI()

            let libWalletInvoice = try doWithError({ error in
                LibwalletParseInvoice(invoice, Environment.current.network, error)
            })

            paymentURI.address = address
            amount.map { paymentURI.amount = "\($0.toBTCDecimal())"}
            paymentURI.invoice = libWalletInvoice

            let uri = try doWithError({ error in
                LibwalletGenerateBip21Uri(paymentURI, error)
            })

            return Single.just(RawBitcoinURI(uri: uri, rawInvoice: invoice, address: address, amount: amount))
        }
    }
}

public struct RawBitcoinURI {
    public let uri: String
    public let rawInvoice: String
    public let address: String
    public let amount: Satoshis?
}
