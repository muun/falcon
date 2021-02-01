//
//  FulfillIncomingSwapAction.swift
//  core.root-all-notifications
//
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

    init(keysRepository: KeysRepository,
         houstonService: HoustonService,
         operationRepository: OperationRepository,
         incomingSwapRepository: IncomingSwapRepository,
         verifyFulfillable: VerifyFulfillableAction
         ) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
        self.operationRepository = operationRepository
        self.incomingSwapRepository = incomingSwapRepository
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
                guard let htlc = swap.htlc else {
                    throw MuunError(Errors.unknownSwap)
                }

                let incomingSwap = LibwalletIncomingSwap()

                incomingSwap.fulfillmentTx = fulfillmentData.fulfillmentTx
                incomingSwap.muunSignature = fulfillmentData.muunSignature
                incomingSwap.outputPath = fulfillmentData.outputPath
                incomingSwap.outputVersion = fulfillmentData.outputVersion

                incomingSwap.htlcTx = htlc.htlcTx
                incomingSwap.paymentHash = swap.paymentHash
                incomingSwap.sphinx = swap.sphinxPacket
                incomingSwap.swapServerPublicKey = htlc.swapServerPublicKey.toHexString()
                incomingSwap.htlcExpiration = htlc.expirationHeight
                incomingSwap.collectInSats = swap.collect.value

                // These are unused for now but should eventually be provided by houston
                incomingSwap.htlcBlock = Data()
                incomingSwap.confirmationTarget = 0
                incomingSwap.blockHeight = 0
                incomingSwap.merkleTree = Data()

                let userKey = try self.keysRepository.getBasePrivateKey()
                let muunKey = try self.keysRepository.getCosigningKey()

                do {
                    let signedTx = try incomingSwap.verifyAndFulfill(
                        userKey.key, muunKey: muunKey.key, net: Environment.current.network
                    )

                    return signedTx
                } catch {

                    if error.localizedDescription.contains("payment is multipart") {
                        throw MuunError(Errors.unfulfillable)
                    } else {
                        throw MuunError(error)
                    }
                }

            }
            .flatMapCompletable { (signedTx: Data) in self.houstonService.pushFulfillmentTransaction(
                    rawTransaction: RawTransaction(hex: signedTx.toHexString()),
                    incomingSwap: swap.uuid
                )

            }
    }

    private func fulfillFullDebt(swap: IncomingSwap) -> Completable {
        return Completable.deferred {
            let preimage = try self.exposePreimage(for: swap.paymentHash)
            return self.houstonService.fulfill(incomingSwap: swap.uuid, preimage: preimage)
        }
    }

    private func exposePreimage(for paymentHash: Data) throws -> Data {

        do {
            return try doWithError { err in
                LibwalletExposePreimage(paymentHash, err)
            }
        } catch {
            throw MuunError(Errors.unknownSwap)
        }
    }

    private func persistPreimage(for swap: IncomingSwap) -> Completable {
        return Completable.deferred {
            let preimage = try self.exposePreimage(for: swap.paymentHash)
            return self.incomingSwapRepository.update(preimage: preimage, for: swap)
        }
    }

    private func verifyFulfillable(swap: IncomingSwap) throws {

        let userKey = try self.keysRepository.getBasePrivateKey()

        do {

            _ = try doWithError { err in LibwalletIsInvoiceFulfillable(
                swap.paymentHash,
                swap.sphinxPacket,
                swap.paymentAmountInSats.value,
                userKey.key,
                Environment.current.network,
                err
            ) }

        } catch {
            throw MuunError(Errors.unfulfillable)
        }
    }

    enum Errors: String, RawRepresentable, Error {
        case unknownSwap
        case unfulfillable
    }

}
