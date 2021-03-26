//
//  CreateInvoiceAction.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 18/09/2020.
//

import Foundation
import Libwallet
import RxSwift

public class CreateInvoiceAction {

    private let keysRepository: KeysRepository
    private let refreshInvoices: RefreshInvoicesAction
    private let forwardingPolicyRepository: ForwardingPolicyRepository
    private let realTimeDataAction: RealTimeDataAction

    init(keysRepository: KeysRepository,
         refreshInvoices: RefreshInvoicesAction,
         forwardingPolicyRepository: ForwardingPolicyRepository,
         realTimeDataAction: RealTimeDataAction) {
        self.keysRepository = keysRepository
        self.refreshInvoices = refreshInvoices
        self.forwardingPolicyRepository = forwardingPolicyRepository
        self.realTimeDataAction = realTimeDataAction
    }

    fileprivate func create(amount: Satoshis?,
                            policy: ForwardingPolicy,
                            userPrivateKey: WalletPrivateKey) throws -> String {

        let routeHints = LibwalletRouteHints()
        routeHints.cltvExpiryDelta = Int32(policy.cltvExpiryDelta)
        routeHints.feeBaseMsat = policy.feeBaseMsat
        routeHints.feeProportionalMillionths = policy.feeProportionalMillionths
        routeHints.pubkey = policy.identityKeyHex

        let options = LibwalletInvoiceOptions()
        options.amountSat = amount?.value ?? 0

        let invoice = try doWithError { err in
            LibwalletCreateInvoice(Environment.current.network,
                                   userPrivateKey.key,
                                   routeHints,
                                   options,
                                   err)
        }

        if invoice.isEmpty {
            throw MuunError(Errors.noInvoicesLeft)
        }

        return invoice
    }

    public func run(amount: Satoshis?) -> Single<String> {

        return Single.deferred { [self] () in

            func getInvoice(policies: [ForwardingPolicy]) throws -> Single<String> {

                guard let policy = policies.randomElement() else {
                    throw MuunError(Errors.noPolicies)
                }

                let userPrivateKey = try keysRepository.getBasePrivateKey()

                return Single.deferred({
                    let invoice = try create(
                        amount: amount,
                        policy: policy,
                        userPrivateKey: userPrivateKey
                    )
                    return Single.just(invoice)
                })
                .catchError { err in
                    if err.contains(Errors.noInvoicesLeft) {
                        return refreshInvoices.getValue()
                            .map { () in
                                return try create(
                                    amount: amount,
                                    policy: policy,
                                    userPrivateKey: userPrivateKey
                                )
                            }
                            .do(onSubscribe: refreshInvoices.run)
                    } else {
                        return Single.error(err)
                    }
                }
            }

            let policies = forwardingPolicyRepository.fetch()
            let single: Single<String>
            if policies.isEmpty {
                realTimeDataAction.run(forceUpdate: true)

                single = realTimeDataAction.getValue().flatMap({ (realTimeData) in
                    return try getInvoice(policies: realTimeData.forwardingPolicies)
                })
            } else {
                single = try getInvoice(policies: policies)
            }

            return single

        }.do(afterSuccess: { _ in
            // We get some reentrancy warnings if we refresh here, so do it async
            DispatchQueue.main.async {
                self.refreshInvoices.run()
            }
        })

    }

    enum Errors: String, Error, RawRepresentable {
        case noPolicies
        case noInvoicesLeft
    }

}
