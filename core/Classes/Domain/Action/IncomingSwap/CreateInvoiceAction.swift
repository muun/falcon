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

    fileprivate func create(with policy: ForwardingPolicy,
                            userPrivateKey: WalletPrivateKey) throws -> String {

        let routeHints = LibwalletRouteHints()
        routeHints.cltvExpiryDelta = Int32(policy.cltvExpiryDelta)
        routeHints.feeBaseMsat = policy.feeBaseMsat
        routeHints.feeProportionalMillionths = policy.feeProportionalMillionths
        routeHints.pubkey = policy.identityKeyHex

        let options = LibwalletInvoiceOptions()
        options.amountSat = 0

        return try doWithError { err in
            LibwalletCreateInvoice(Environment.current.network,
                                   userPrivateKey.key,
                                   routeHints,
                                   options,
                                   err)
        }
    }

    public func run() -> Single<String> {

        return Single.deferred { [self] () in

            func getInvoice(policies: [ForwardingPolicy]) throws -> Single<String> {

                guard let policy = policies.randomElement() else {
                    throw MuunError(Errors.noPolicies)
                }

                let userPrivateKey = try keysRepository.getBasePrivateKey()

                return Single.deferred({
                    Single.just(try create(with: policy, userPrivateKey: userPrivateKey))
                })
                .catchError { _ in
                    return refreshInvoices.getValue()
                        .map { () in
                            try create(with: policy, userPrivateKey: userPrivateKey)
                        }
                        .do(onSubscribe: refreshInvoices.run)
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
    }

}
