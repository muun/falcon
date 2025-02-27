//
//  VerifyFulfillableAction.swift
//  Created by Juan Pablo Civile on 18/01/2021.
//

import Foundation
import RxSwift
import Libwallet

class VerifyFulfillableAction {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository, houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
    }

    func action(swap: IncomingSwap) -> Completable {

        return Completable.deferred {

            let userKey = try self.keysRepository.getBasePrivateKey()

            do {
                try swap.verifyFulfillable(userKey: userKey)
            } catch {
                Logger.log(error: error)
                return self.houstonService.expireInvoice(swap.paymentHash.toHexString())
            }
            return Completable.empty()

        }
    }

}
