//
//  OperationActions.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift
import Libwallet

public class OperationActions {

    private let operationRepository: OperationRepository
    private let houstonService: HoustonService
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let feeWindowRepository: FeeWindowRepository
    private let keysRepository: KeysRepository
    private let verifyFulfillable: VerifyFulfillableAction
    private let notificationScheduler: NotificationScheduler
    private let operationMetadataDecrypter: OperationMetadataDecrypter
    private let libwalletService: LibwalletService

    init(operationRepository: OperationRepository,
         houstonService: HoustonService,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         feeWindowRepository: FeeWindowRepository,
         keysRepository: KeysRepository,
         verifyFulfillable: VerifyFulfillableAction,
         notificationScheduler: NotificationScheduler,
         libwalletService: LibwalletService) {

        self.operationRepository = operationRepository
        self.houstonService = houstonService
        self.nextTransactionSizeRepository = nextTransactionSizeRepository
        self.feeWindowRepository = feeWindowRepository
        self.keysRepository = keysRepository
        self.verifyFulfillable = verifyFulfillable
        self.notificationScheduler = notificationScheduler
        self.operationMetadataDecrypter = OperationMetadataDecrypter(keysRepository: keysRepository)
        self.libwalletService = libwalletService
    }

    public func getOperationsChange() -> Observable<OperationsChange> {
        return operationRepository.watchOperationsChange()
    }

    public func getOperationsLazy() -> Observable<LazyLoadedList<Operation>> {
        return operationRepository.watchOperationsLazy()
    }

    public func getOperationsState() -> OperationsState {
        return operationRepository.getOperationsState()
    }

    func updateOperations() -> Completable {
        return houstonService.fetchOperations()
            .asObservable()
            .flatMap({ self.operationRepository.storeOperations($0) })
            .asCompletable()
    }

    func received(newOperation: Notification.NewOperation) -> Completable {

        return applyMetadata(newOperation.operation)
            .flatMap { operation in
                self.operationRepository.storeOperations([operation])
                    .andThen(.just(operation))
            }
            .do(onSuccess: self.cleanupNotifications)
            .flatMapCompletable({ operation in
                if let swap = operation.incomingSwap {
                    return self.verifyFulfillable.action(swap: swap)
                } else {
                    return Completable.empty()
                }
            })
            .do(onCompleted: {
                let nts = newOperation.nextTransactionSize
                self.nextTransactionSizeRepository.setNextTransactionSize(nts)
            })

    }

    private func applyMetadata(_ operation: Operation) -> Single<Operation> {
        return Single.deferred {
            if let swap = operation.incomingSwap,
               let metadata = self.getInvoiceMetadata(swap) {

                let metadataJson = try self.operationMetadataDecrypter.decrypt(metadata: metadata)

                var op = operation
                op.metadata = metadataJson

                if let invoice = metadataJson?.invoice {
                    let parsedInvoice = try doWithError { error in
                        LibwalletParseInvoice(invoice, Environment.current.network, error)
                    }
                    op.description = parsedInvoice.description
                }

                return self.houstonService.updateOperationMetadata(
                    operationId: op.id!,
                    metadata: metadata
                ).andThen(.just(op))
            }
            return .just(operation)
        }
    }

    func getInvoiceMetadata(_ swap: IncomingSwap) -> String? {
        do {
            let metadata = try doWithError({ error in
                LibwalletGetInvoiceMetadata(swap.paymentHash, error)
            })
            if metadata == "" {
                return nil
            }
            return metadata
        } catch {
            Logger.log(.warn, "failed to obtain invoice metadata: \(error)")
        }
        return nil
    }

    func cleanupNotifications(_ operation: Operation) {
        if let paymentHash = operation.incomingSwap?.paymentHash,
           operation.metadata?.lnurlSender != nil {
            notificationScheduler.cancelNotifications(paymentHash: paymentHash)
        }
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
        let key = try keysRepository.getBasePrivateKey()
            .derive(to: .metadata)
            .deriveRandom()
            .deriveRandom()

        let metadata = JSONEncoder.data(json: OperationMetadataJson(description: description))
        return try key.encrypt(payload: metadata)
    }

    private func logOnStaleNTS(_ newNTS: NextTransactionSize) {
        if let currentOperationId =
            nextTransactionSizeRepository.getNextTransactionSize()?.validAtOperationHid,
           let newOperationId = newNTS.validAtOperationHid,
           currentOperationId >= newOperationId {
            Logger.log(
                .err,
                "NTS returned by PushTransaction has not changes."
            )
        }
    }

    // swiftlint:disable function_body_length
    public func newOperation(
        _ operation: Operation,
        with swapParameters: SwapExecutionParameters? = nil,
        maxAlternativeTransactionCount: Int = 0
    ) -> Single<Operation> {

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

        let nonceCount = json.outpoints?.count ?? 0
        let nonces = LibwalletGenerateMusigNonces(nonceCount)!
        var noncesForAlternativeTransactions: [LibwalletMusigNonces] = []
        for _ in 0..<maxAlternativeTransactionCount {
            noncesForAlternativeTransactions.append(LibwalletGenerateMusigNonces(nonceCount)!)
        }

        var noncesHex = [String]()
        for i in 0..<nonceCount {
            noncesHex.append(nonces.getPubnonceHex(i))
        }
        // I mean, this looks really ugly. Maybe we should send an array of arrays of nonces for alternative txs
        for nonces in noncesForAlternativeTransactions {
            for i in 0..<nonceCount {
                noncesHex.append(nonces.getPubnonceHex(i))
            }
        }

        json.userPublicNoncesHex = noncesHex

        return houstonService.newOperation(operation: json)
            .flatMap({ created in

                // TODO: only allow alternative TXs for 0-conf swaps
                precondition(maxAlternativeTransactionCount >= created.alternativeTransactions.count)

                let rawTransaction: RawTransaction?
                let alternativeTransactions: [RawTransaction]
                var operationUpdated = created.operation

                if case .LEND = swapParameters?.debtType {
                    // If we are on a lend swap we don't need to sign anything because there wont be a transaction
                    rawTransaction = nil
                    alternativeTransactions = []
                } else {
                    // Sign the transaction
                    let privateKey = try self.keysRepository.getBasePrivateKey()
                    let muunKey = try self.keysRepository.getCosigningKey()

                    let expectations = PartiallySignedTransaction.Expectations(
                        destination: destinationAddress,
                        amount: outputAmount,
                        fee: operation.fee.inSatoshis,
                        change: created.change,
                        alternative: false
                    )

                    let signedTransaction = try created.partiallySignedTransaction.sign(
                        key: privateKey,
                        muunKey: muunKey,
                        expectations: expectations,
                        nonces: nonces
                    )

                    var signedAlternativeTransactions: [PartiallySignedTransaction.SignedTransaction] = []
                    for (i, alternativeTransaction) in created.alternativeTransactions.enumerated() {
                        signedAlternativeTransactions.append(try alternativeTransaction.sign(
                            key: privateKey,
                            muunKey: muunKey,
                            expectations: expectations.toAlternative(),
                            nonces: noncesForAlternativeTransactions[i]
                        ))
                    }

                    operationUpdated.transaction?.hash = signedTransaction.hash
                    operationUpdated.status = .SIGNED

                    rawTransaction = RawTransaction(hex: signedTransaction.bytes.toHexString())
                    alternativeTransactions = signedAlternativeTransactions.map({ tx in
                        RawTransaction(hex: tx.bytes.toHexString())
                    })
                }

                return self.houstonService.pushTransactions(
                    rawTransaction: rawTransaction,
                    alternativeTransactions: alternativeTransactions,
                    operationId: operationUpdated.id!
                )
                    .map { pushTxResponse in
                        self.logOnStaleNTS(pushTxResponse.nextTransactionSize)
                        self.nextTransactionSizeRepository
                            .setNextTransactionSize(pushTxResponse.nextTransactionSize)
                        self.libwalletService.persistFeeBumpFunctions(
                            feeBumpFunctions: pushTxResponse.feeBumpFunctions,
                            refreshPolicy: .ntsChanged
                        )
                        operationUpdated.status = pushTxResponse.updatedOperation.status
                        return operationUpdated
                    }
                    .flatMap({ op in
                        self.operationRepository.storeOperations([op]).andThen(
                            Single.just(op)
                        )
                    })
                    .catchError({ error in
                        if let muunError = error as? MuunError,
                           let serviceError = muunError.kind as? ServiceError,
                           serviceError.isTimeout() {

                            operationUpdated.status = .FAILED
                            return self.operationRepository.storeOperations([operationUpdated]).andThen(
                                Single.error(error)
                            )
                        }

                        return Single.error(error)
                    })
            })
    }

    public func hasOperations() -> Bool {
        return operationRepository.count() > 0
    }

    public func hasPendingOperations(includeUnsettled: Bool = true) -> Bool {
        return operationRepository.hasPendingOperations(includeUnsettled: includeUnsettled)
    }

    public func hasPendingSwaps() -> Bool {
        return operationRepository.hasPendingSwaps()
    }

    public func hasPendingIncomingSwaps() -> Bool {
        return operationRepository.hasPendingIncomingSwaps()
    }

    public func watch(operation: Operation) -> Observable<Operation> {
        guard let id = operation.id else {
            return Observable.error(MuunError(Errors.invalidOperation))
        }

        return operationRepository.watchObject(with: id)
    }

    enum Errors: Error {
        case invalidOperation
    }
}
