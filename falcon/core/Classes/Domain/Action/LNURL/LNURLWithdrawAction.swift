//
//  LNURLWithdrawAction.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 09/04/2021.
//

import Foundation
import RxSwift
import Libwallet

public class LNURLWithdrawAction {

    public enum State {
        case contacting(domain: String)
        case invoice(_ invoice: String, paymentHash: Data, expires: Date, domain: String)
        case receiving(domain: String)
        case tooLong(domain: String)
        case success
        case failed(error: MuunError)
    }

    public enum WithdrawError: Equatable, Error {
        case invalidCode(message: String)
        case unresponsive(message: String, domain: String)
        case wrongTag(message: String)
        case requestExpired(message: String)
        case noAvailableBalance(message: String, domain: String)
        case noRoute(message: String, domain: String)
        case unknown(message: String)
        case expiredInvoice(domain: String)
        case countryNotSupported(message: String, domain: String)
        case alreadyUsed(message: String, domain: String)
    }

    private let keysRepository: KeysRepository
    private let operationRepository: OperationRepository
    private let forwardingPolicyRepository: ForwardingPolicyRepository
    private let refreshInvoicesAction: RefreshInvoicesAction

    init(keysRepository: KeysRepository,
         operationRepository: OperationRepository,
         forwardingPolicyRepository: ForwardingPolicyRepository,
         refreshInvoicesAction: RefreshInvoicesAction) {
        self.keysRepository = keysRepository
        self.operationRepository = operationRepository
        self.forwardingPolicyRepository = forwardingPolicyRepository
        self.refreshInvoicesAction = refreshInvoicesAction
    }

    public func preflight(qr: String) -> Bool {
        return LibwalletLNURLValidate(qr)
    }

    public func run(_ qr: String) -> Observable<State> {

        refreshInvoicesAction.run()

        return refreshInvoicesAction.getValue()
            .asCompletable()
            .andThen(processLNURL(qr))
    }

    private func waitForPayment(withHash paymentHash: Data) -> Observable<State> {
        return operationRepository.watchOperationsChange().filter { change in
            if let operation = change.lastOperation,
               let swap = operation.incomingSwap {

                if swap.paymentHash == paymentHash {
                    return true
                }
            }
            return false
        }.map { _ in State.success }
    }

    private func processLNURL(_ qr: String) -> Observable<State> {

        return Observable.deferred {

            let userKey: WalletPrivateKey
            let policies: [ForwardingPolicy]
            do {
                userKey = try self.keysRepository.getBasePrivateKey()
                policies = self.forwardingPolicyRepository.fetch()
            } catch {
                Logger.log(error: error)
                let wrappedError = MuunError(WithdrawError.unknown(message: error.localizedDescription))
                return Observable.just(.failed(error: wrappedError))
            }

            let builder = LibwalletInvoiceBuilder()
                    .network(Environment.current.network)?
                    .userKey(userKey.key)

            for policy in policies {
                let routeHints = LibwalletRouteHints()
                routeHints.cltvExpiryDelta = Int32(policy.cltvExpiryDelta)
                routeHints.feeBaseMsat = policy.feeBaseMsat
                routeHints.feeProportionalMillionths = policy.feeProportionalMillionths
                routeHints.pubkey = policy.identityKeyHex
                builder?.add(routeHints)
            }

            let listener = RxListener()

            LibwalletLNURLWithdraw(
                builder,
                qr,
                listener
            )

            return listener.asObservable().flatMap { state -> Observable<State> in
                switch state {
                // schedule payment taking too long message 15 seconds after "receiving" message
                case .receiving(let domain):
                    return Observable.just(
                        State.tooLong(domain: domain)
                    ).delay(.seconds(15), scheduler: MainScheduler.asyncInstance)
                    .startWith(State.receiving(domain: domain))

                // schedule invoice expired error message after invoice expiration
                case .invoice(_, let paymentHash, let expires, let domain):

                    let secondsToExpiry = Int(ceil(expires.timeIntervalSince(Date())))
                    let wrappedError = MuunError(WithdrawError.expiredInvoice(domain: domain))

                    return Observable.merge(
                        Observable.just(State.failed(error: wrappedError)).delay(
                            .seconds(secondsToExpiry),
                            scheduler: MainScheduler.asyncInstance
                        ),
                        self.waitForPayment(withHash: paymentHash)
                    ).startWith(state)

                // pass-through for other states
                default:
                    return .just(state)
                }
            }
        }
    }

    fileprivate class RxListener: NSObject, LibwalletLNURLListenerProtocol {
        private let subject = ReplaySubject<State>.create(bufferSize: 25)

        func onError(_ e: LibwalletLNURLEvent?) {
            if let event = e {
                var error: WithdrawError
                switch event.code {
                case LibwalletLNURLErrDecode, LibwalletLNURLErrUnsafeURL:
                    error = .invalidCode(message: event.message)
                case LibwalletLNURLErrWrongTag:
                    error = .wrongTag(message: event.message)
                case LibwalletLNURLErrUnreachable:
                    error = .unresponsive(message: event.message, domain: event.metadata!.host)
                case LibwalletLNURLErrRequestExpired:
                    error = .requestExpired(message: event.message)
                case LibwalletLNURLErrNoAvailableBalance:
                    error = .noAvailableBalance(message: event.message, domain: event.metadata!.host)
                case LibwalletLNURLErrNoRoute:
                    error = .noRoute(message: event.message, domain: event.metadata!.host)
                case LibwalletLNURLErrCountryNotSupported:
                    error = .countryNotSupported(message: event.message, domain: event.metadata!.host)
                case LibwalletLNURLErrForbidden:
                    error = .unknown(message: event.message)
                case LibwalletLNURLErrAlreadyUsed:
                    error = .alreadyUsed(message: event.message, domain: event.metadata!.host)
                default:
                    error = .unknown(message: event.message)
                }
                Logger.log(.err, "LNURL Withdraw Error: \(event.message)")
                subject.onNext(.failed(error: MuunError(error)))
            }
        }

        func onUpdate(_ e: LibwalletLNURLEvent?) {
            if let event = e {
                switch event.code {
                case LibwalletLNURLStatusContacting:
                    subject.onNext(.contacting(domain: event.metadata!.host))
                case LibwalletLNURLStatusReceiving:
                    subject.onNext(.receiving(domain: event.metadata!.host))
                case LibwalletLNURLStatusInvoiceCreated:
                    let details = parseInvoice(event.metadata!.invoice)
                    subject.onNext(.invoice(event.metadata!.invoice,
                                            paymentHash: details.paymentHash!,
                                            expires: Date(timeIntervalSince1970: Double(details.expiry)),
                                            domain: event.metadata!.host))
                default:
                    break // ignore
                }
            }
        }

        func asObservable() -> Observable<State> {
            return subject.asObservable()
        }
    }

}

fileprivate func parseInvoice(_ invoice: String) -> LibwalletInvoice {
    do {
        return try doWithError { error in
            LibwalletParseInvoice(invoice, Environment.current.network, error)
        }
    } catch {
        fatalError("\(error)")
    }
}
