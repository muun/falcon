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
         incomingSwapRepository: IncomingSwapRepository) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
        self.operationRepository = operationRepository
        self.incomingSwapRepository = incomingSwapRepository
    }

    func run(uuid: String) -> Completable {
        let comp = Single.zip(fetchOperation(swapUuid: uuid), houstonService.fetchFulfillmentData(for: uuid))
            .flatMap(self.signTransaction)
            .flatMap({ (op, rawTx) in
                self.houstonService.pushFulfillmentTransaction(
                    rawTransaction: RawTransaction(hex: rawTx.toHexString()),
                    incomingSwap: uuid
                ).andThen(Single.just(op))
            })
            .flatMapCompletable({ (op: Operation) in return Completable.deferred {
                let swap = op.incomingSwap!
                let preimage = try doWithError { err in
                    LibwalletExposePreimage(swap.paymentHash, err)
                }

                return self.incomingSwapRepository.update(preimage: preimage, for: swap)
            }})
            .catchError { error in
                if error.isKindOf(.incomingSwapAlreadyFulfilled) {
                    return Completable.empty()
                } else if error.contains(Errors.unknownSwap) {
                    Logger.log(error: error)
                    return Completable.empty()
                } else {
                    return Completable.error(error)
                }
            }
            // TODO: RECEIVE: We should persist the signed tx in local storage too
        return comp
    }

    private func fetchOperation(swapUuid: String) -> Single<Operation> {
        return Single.deferred({
            if let op = self.operationRepository.findByIncomingSwap(uuid: swapUuid) {
                return Single.just(op)
            } else {
                return Single.error(MuunError(Errors.unknownSwap))
            }
        })
    }

    private func signTransaction(op: Operation, fulfillmentData: IncomingSwapFulfillmentData) -> Single<(Operation, Data)> {
        return Single.deferred({
            guard let swap = op.incomingSwap,
                  let htlc = swap.htlc else {
                return Single.error(MuunError(Errors.unknownSwap))
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

            let signedTx = try incomingSwap.verifyAndFulfill(
                userKey.key, muunKey: muunKey.key, net: Environment.current.network
            )

            return Single.just((op, signedTx))
        })
    }

    enum Errors: String, RawRepresentable, Error {
        case unknownSwap
    }

}
