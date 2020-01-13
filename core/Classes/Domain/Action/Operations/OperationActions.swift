//
//  OperationActions.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class OperationActions {

    private let operationRepository: OperationRepository
    private let houstonService: HoustonService
    private let currencyActions: CurrencyActions
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let feeWindowRepository: FeeWindowRepository
    private let keysRepository: KeysRepository

    private let balanceCache: BehaviorSubject<MonetaryAmount>
    private let disposeBag: DisposeBag

    init(operationRepository: OperationRepository,
         houstonService: HoustonService,
         currencyActions: CurrencyActions,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         feeWindowRepository: FeeWindowRepository,
         keysRepository: KeysRepository) {

        self.operationRepository = operationRepository
        self.houstonService = houstonService
        self.currencyActions = currencyActions
        self.nextTransactionSizeRepository = nextTransactionSizeRepository
        self.feeWindowRepository = feeWindowRepository
        self.keysRepository = keysRepository

        self.disposeBag = DisposeBag()
        self.balanceCache = BehaviorSubject(value: MonetaryAmount(amount: 0, currency: "BTC"))

        generateBalanceCache()
    }

    func watchBalanceInSatoshis() -> Observable<Satoshis> {
        return nextTransactionSizeRepository.watchNextTransactionSize()
            .map({ nextSize in nextSize?.sizeProgression.last?.amountInSatoshis })
            .map({ amount in amount ?? Satoshis(value: 0) })
    }

    private func generateBalanceCache() {

        let satoshisObservable = watchBalanceInSatoshis()

        let disposable = Observable.combineLatest(satoshisObservable, currencyActions.watchPrimaryExchangeRate())
            .map({ (inSatoshis: Satoshis, exchangeRate: (String, Decimal)?) -> MonetaryAmount in
                guard let exchangeRate = exchangeRate else {
                    return MonetaryAmount(amount: 0, currency: "BTC")
                }

                let (currency, rate) = exchangeRate
                return inSatoshis.valuation(at: rate, currency: currency)
            })
            .subscribe(onNext: self.balanceCache.onNext)

        disposeBag.insert(disposable)
    }

    public func getOperations() -> Observable<[core.Operation]> {
        return operationRepository.watchOperations()
    }

    func updateOperations() -> Completable {
        return houstonService.fetchOperations()
            .asObservable()
            .flatMap({ self.operationRepository.storeOperations($0) })
            .asCompletable()
    }

    public func watchBalance() -> Observable<MonetaryAmount> {
        return balanceCache.asObservable()
    }

    func recieved(newOperation: Notification.NewOperation) -> Completable {
        return operationRepository.storeOperations([newOperation.operation])
            .do(onCompleted: {
                self.nextTransactionSizeRepository.setNextTransactionSize(newOperation.nextTransactionSize)
            })
    }

    func operationUpdated(_ update: Notification.OperationUpdate) -> Completable {
        return Completable.deferred({

            guard var operation = self.operationRepository.object(with: update.id) else {
                return Completable.empty()
            }

            operation.confirmations = update.confirmations
            operation.status = update.status
            operation.transaction?.confirmations = update.confirmations
            operation.transaction?.hash = update.hash
            operation.submarineSwap = update.swapDetails

            self.nextTransactionSizeRepository.setNextTransactionSize(update.nextTransactionSize)
            return self.operationRepository.storeOperations([operation])
        })
    }

    public func newOperation(_ operation: core.Operation) -> Single<core.Operation> {

        guard let destinationAddress = operation.receiverAddress else {
            Logger.fatal("Tried to create new operation without a destination address")
        }

        return houstonService.newOperation(operation: operation)
            .flatMap({ created in
                let privateKey = try self.keysRepository.getBasePrivateKey()
                let muunKey = try self.keysRepository.getCosigningKey()

                let expectations = PartiallySignedTransaction.Expectations(
                    destination: destinationAddress,
                    amount: operation.outputAmount,
                    fee: operation.fee.inSatoshis,
                    change: created.change)

                let signedTransaction = try created.partiallySignedTransaction.sign(
                    key: privateKey,
                    muunKey: muunKey,
                    expectations: expectations)

                var operationUpdated = created.operation
                operationUpdated.transaction?.hash = signedTransaction.hash
                operationUpdated.status = .SIGNED

                return self.houstonService.pushTransaction(
                    rawTransaction: RawTransaction(hex: signedTransaction.bytes!.toHexString()),
                    operationId: operationUpdated.id!)
                    .do(onSuccess: { completedOp in
                        self.nextTransactionSizeRepository.setNextTransactionSize(completedOp.nextTransactionSize)
                    })
                    .flatMap({ _ in
                        self.operationRepository.storeOperations([operationUpdated]).andThen(
                            Single.just(operationUpdated)
                        )
                    })
            })
    }

    func hasOperations() -> Bool {
        return operationRepository.count() > 0
    }

    public func watch(operation: core.Operation) -> Observable<core.Operation> {
        guard let id = operation.id else {
            return Observable.error(MuunError(Errors.invalidOperation))
        }

        return operationRepository.watchObject(with: id)
    }

    enum Errors: Error {
        case invalidOperation
    }
}
