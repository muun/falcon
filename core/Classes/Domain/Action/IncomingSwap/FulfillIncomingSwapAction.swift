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

    init(keysRepository: KeysRepository,
         houstonService: HoustonService,
         operationRepository: OperationRepository) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
        self.operationRepository = operationRepository
    }

    func run(uuid: String) -> Completable {
        return Single.zip(fetchOperation(swapUuid: uuid), houstonService.fetchFulfillmentData(for: uuid))
            .flatMap(self.signTransaction)
            .flatMapCompletable({ rawTx in
                self.houstonService.pushFulfillmentTransaction(
                    rawTransaction: RawTransaction(hex: rawTx.toHexString()),
                    incomingSwap: uuid
                )
            })
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

    private func signTransaction(op: Operation, fulfillmentData: IncomingSwapFulfillmentData) -> Single<Data> {
        return Single.deferred({
            guard let swap = op.incomingSwap else {
                return Single.error(MuunError(Errors.unknownSwap))
            }

            let incomingSwap = LibwalletIncomingSwap()

            incomingSwap.fulfillmentTx = fulfillmentData.fulfillmentTx
            incomingSwap.muunSignature = fulfillmentData.muunSignature
            incomingSwap.outputPath = fulfillmentData.outputPath
            incomingSwap.outputVersion = fulfillmentData.outputVersion

            incomingSwap.htlcTx = swap.htlc.htlcTx
            incomingSwap.paymentHash = swap.paymentHash
            incomingSwap.sphinx = swap.sphinxPacket
            incomingSwap.swapServerPublicKey = swap.htlc.swapServerPublicKey.toHexString()
            incomingSwap.htlcExpiration = swap.htlc.expirationHeight

            // These are unused for now but should eventually be provided by houston
            incomingSwap.htlcBlock = Data()
            incomingSwap.confirmationTarget = 0
            incomingSwap.blockHeight = 0
            incomingSwap.merkleTree = Data()

            let userKey = try self.keysRepository.getBasePrivateKey()
            let muunKey = try self.keysRepository.getCosigningKey()

            let signedTx = try incomingSwap.verifyAndFulfill(userKey.key, muunKey: muunKey.key, net: Environment.current.network)

            return Single.just(signedTx)
        })
    }

    enum Errors: String, RawRepresentable, Error {
        case unknownSwap
    }

}
