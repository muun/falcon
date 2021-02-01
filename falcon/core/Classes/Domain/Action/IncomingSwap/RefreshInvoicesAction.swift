//
//  RefreshInvoicesAction.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 18/09/2020.
//

import Foundation
import Libwallet
import RxSwift

public class RefreshInvoicesAction: AsyncAction<()>, Runnable {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository, houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
        super.init(name: "RefreshInvoicesAction")
    }

    public func run() {

        let action = Completable.deferred({ [self] in

            let userKey = try keysRepository.getBasePublicKey()
            let muunKey = try keysRepository.getCosigningKey()

            let invoices = try doWithError { err in
                LibwalletGenerateInvoiceSecrets(userKey.key, muunKey.key, err)
            }

            var toRegister: [UserInvoiceJson] = []

            // This is full of ! because of libwallet bridging
            // None of the invoice fields is optional
            for i in 0..<invoices.length() {
                let invoice = invoices.get(i)!

                toRegister.append(UserInvoiceJson(
                    paymentHashHex: invoice.paymentHash!.toHexString(),
                    shortChannelId: invoice.shortChanId,
                    userPublicKey: WalletPublicKey(invoice.userHtlcKey!).toJson(),
                    muunPublicKey: WalletPublicKey(invoice.muunHtlcKey!).toJson(),
                    identityPubKey: WalletPublicKey(invoice.identityKey!).toJson()
                ))
            }

            return houstonService.registerInvoices(toRegister)
                .andThen(Completable.deferred({
                    _ = try doWithError({ error in
                        LibwalletPersistInvoiceSecrets(invoices, error)
                    })

                    return Completable.empty()
                }))
        })

        runCompletable(action)
    }

}
