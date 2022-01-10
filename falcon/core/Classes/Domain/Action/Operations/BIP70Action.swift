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

        return Single.just(FlowToAddress(uri: newUri.adapt()))
    }

}
