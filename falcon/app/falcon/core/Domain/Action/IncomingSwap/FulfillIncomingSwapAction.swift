//
//  FulfillIncomingSwapAction.swift
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation
import RxSwift
import Libwallet

class FulfillIncomingSwapAction {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService
    private let operationRepository: OperationRepository
    private let incomingSwapRepository: IncomingSwapRepository
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let libwalletService: LibwalletService

    init(keysRepository: KeysRepository,
         houstonService: HoustonService,
         operationRepository: OperationRepository,
         incomingSwapRepository: IncomingSwapRepository,
         verifyFulfillable: VerifyFulfillableAction,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         libwalletService: LibwalletService
         ) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
        self.operationRepository = operationRepository
        self.incomingSwapRepository = incomingSwapRepository
        self.nextTransactionSizeRepository = nextTransactionSizeRepository
        self.libwalletService = libwalletService
    }

    func run(uuid: String) -> Completable {
        let comp = fetchSwap(swapUuid: uuid)
            .flatMapCompletable { swap in

                let fulfill: Completable
                if swap.htlc != nil {
                    fulfill = self.fulfillOnChain(swap: swap)
                } else {
                    fulfill = self.fulfillFullDebt(swap: swap)
                }

                return Completable.executing {
                        try self.verifyFulfillable(swap: swap)
                    }
                    .andThen(fulfill)
                    .andThen(self.persistPreimage(for: swap))
                    .catchError { error in
                        if error.contains(Errors.unknownSwap) || error.contains(Errors.unfulfillable) {
                            return self.houstonService.expireInvoice(swap.paymentHash.toHexString())

                        } else if error.isKindOf(.incomingSwapAlreadyFulfilled) {
                            return Completable.empty()

                        } else {
                            return Completable.error(error)
                        }
                    }

            }
            // TODO: RECEIVE: We should persist the signed tx in local storage too

        return comp
    }

    private func fetchSwap(swapUuid: String) -> Single<IncomingSwap> {
        return Single.deferred({
            if let op = self.operationRepository.findByIncomingSwap(uuid: swapUuid),
               let swap = op.incomingSwap {
                return Single.just(swap)
            } else {
                return Single.error(MuunError(Errors.unknownSwap))
            }
        })
    }

    private func fulfillOnChain(swap: IncomingSwap) -> Completable {

        return houstonService.fetchFulfillmentData(for: swap.uuid)
            .map { fulfillmentData in
                if swap.htlc == nil {
                    throw MuunError(Errors.unknownSwap)
                }

                let userKey = try self.keysRepository.getBasePrivateKey()
                let muunKey = try self.keysRepository.getCosigningKey()

                do {
                    return try swap.fulfill(
                        fulfillmentData, userKey: userKey, muunKey: muunKey)
                } catch {

                    if error.localizedDescription.contains("payment is multipart") {
                        throw MuunError(Errors.unfulfillable)
                    } else {
                        throw MuunError(error)
                    }
                }

            }
            .flatMapCompletable { (result: IncomingSwapFulfillmentResult) in
                let fullfillmentTx = RawTransaction(hex: result.fullfillmentTx.toHexString())

                return self.houstonService.pushFulfillmentTransaction(
                    rawTransaction: fullfillmentTx,
                    incomingSwap: swap.uuid
                ).flatMapCompletable { [weak self] fulfillmentResult in
                    Completable.executing {
                        self?.nextTransactionSizeRepository
                            .setNextTransactionSize(fulfillmentResult.nextTransactionSize)
                        self?.libwalletService.persistFeeBumpFunctions(
                            feeBumpFunctions: fulfillmentResult.feeBumpFunctions,
                            refreshPolicy: .ntsChanged
                        )
                    }
                }
            }
    }

    private func fulfillFullDebt(swap: IncomingSwap) -> Completable {
        return Completable.deferred {
            let preimage: Data
            do {
                preimage = try swap.fulfillFullDebt()
            } catch {
                throw MuunError(Errors.unknownSwap)
            }

            return self.houstonService.fulfill(incomingSwap: swap.uuid, preimage: preimage)
        }
    }

    private func persistPreimage(for swap: IncomingSwap) -> Completable {
        return Completable.deferred {
            guard let preimage = swap.preimage else {
                fatalError("expected swap to contain preimage after fulfillment")
            }
            return self.incomingSwapRepository.update(preimage: preimage, for: swap)
        }
    }

    private func verifyFulfillable(swap: IncomingSwap) throws {

        let userKey = try self.keysRepository.getBasePrivateKey()

        do {
            try swap.verifyFulfillable(userKey: userKey)
        } catch {
            throw MuunError(Errors.unfulfillable)
        }
    }

    enum Errors: String, RawRepresentable, Error {
        case unknownSwap
        case unfulfillable
    }

}
