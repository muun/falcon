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
            .map({ nts in
                return nts?.uiBalance() ?? Satoshis(value: 0)
            })
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

    func received(newOperation: Notification.NewOperation) -> Completable {
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

    private func generateMetadata(description: String?) throws -> String {

        // Derive a key for metadata in it's tree on two random indexes to make it reasonably unique
        let encrypter = try keysRepository.getBasePrivateKey()
            .derive(to: .metadata)
            .deriveRandom()
            .deriveRandom()
            .encrypter()

        let metadata = JSONEncoder.data(json: OperationMetadataJson(description: description))
        return try doWithError({ err in
            encrypter.encrypt(metadata, error: err)
        })
    }

    public func newOperation(_ operation: core.Operation, with swapParameters: SwapExecutionParameters? = nil) -> Single<core.Operation> {

        guard let destinationAddress = operation.receiverAddress else {
            Logger.fatal("Tried to create new operation without a destination address")
        }

        let outputAmount: Satoshis
        if let parameters = swapParameters {
            let debtAmount: Satoshis
            if parameters.debtType == .COLLECT {
                debtAmount = parameters.debtAmount
            } else {
                debtAmount = Satoshis(value: 0)
            }

            outputAmount = parameters.offchainFee + operation.amount.inSatoshis + debtAmount
        } else {
            outputAmount = operation.amount.inSatoshis
        }

        var json = operation.toJson()
        json.outputAmountInSatoshis = outputAmount.value
        do {
            json.senderMetadata = try generateMetadata(description: operation.description)
            json.description = nil
        } catch {
            Logger.log(error: error)
        }

        return houstonService.newOperation(operation: json)
            .flatMap({ created in

                let rawTransaction: RawTransaction?
                var operationUpdated = created.operation

                if case .LEND = swapParameters?.debtType {
                    // If we are on a lend swap we don't need to sign anything because there wont be a transaction
                    rawTransaction = nil
                } else {
                    // Sign the transaction
                    let privateKey = try self.keysRepository.getBasePrivateKey()
                    let muunKey = try self.keysRepository.getCosigningKey()

                    let expectations = PartiallySignedTransaction.Expectations(
                        destination: destinationAddress,
                        amount: outputAmount,
                        fee: operation.fee.inSatoshis,
                        change: created.change)

                    let signedTransaction = try created.partiallySignedTransaction.sign(
                        key: privateKey,
                        muunKey: muunKey,
                        expectations: expectations)

                    operationUpdated.transaction?.hash = signedTransaction.hash
                    operationUpdated.status = .SIGNED

                    rawTransaction = RawTransaction(hex: signedTransaction.bytes.toHexString())
                }

                return self.houstonService.pushTransaction(
                    rawTransaction: rawTransaction,
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
