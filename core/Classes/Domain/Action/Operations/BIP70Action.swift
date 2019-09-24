//
//  BIP70Action.swift
//  core
//
//  Created by Manu Herrera on 31/05/2019.
//

import Foundation
import Libwallet
import RxSwift

public class BIP70Action: AsyncAction<PaymentRequestType> {

    public init() {
        super.init(name: "BIP70Action")
    }

    public func getPaymentRequest(url: String) throws -> Single<PaymentRequestType> {
        let newUri = try doWithError { error in
            LibwalletDoPaymentRequestCall(url, Environment.current.network, error)
        }

        let sats = Satoshis(value: Int64(newUri.amount)!)

        let newMuunUri = MuunPaymentURI(address: newUri.address,
                                        label: newUri.label,
                                        message: newUri.message,
                                        amount: sats.toBTC().amount,
                                        others: [:],
                                        uri: URL(string: newUri.biP70Url)!,
                                        bip70URL: newUri.biP70Url,
                                        creationTime: newUri.creationTime,
                                        expiresTime: newUri.expiresTime)

        return Single.just(PaymentRequestType.toAddress(uri: newMuunUri))
    }

}
