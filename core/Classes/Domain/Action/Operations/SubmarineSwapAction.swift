//
//  SubmarineSwapAction.swift
//  falcon
//
//  Created by Manu Herrera on 05/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public class SubmarineSwapAction: AsyncAction<(SubmarineSwap)> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let blockchainHeightRepository: BlockchainHeightRepository

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         blockchainHeightRepository: BlockchainHeightRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.blockchainHeightRepository = blockchainHeightRepository

        super.init(name: "SubmarineSwapAction")
    }

    public func run(invoice: String, swapExpirationInBlocks: Int) {
        let submarineSwapRequest = SubmarineSwapRequest(invoice: invoice,
                                                        swapExpirationInBlocks: swapExpirationInBlocks)
        runSingle(
            houstonService.createSubmarineSwap(submarineSwapRequest: submarineSwapRequest)
                .map({ swap in
                    let isValid = try doWithError({ err in
                        LibwalletValidateSubmarineSwap(invoice,
                                                       try self.keysRepository.getBasePublicKey().key,
                                                       try self.keysRepository.getCosigningKey().key,
                                                       swap,
                                                       Int64(swapExpirationInBlocks),
                                                       Environment.current.network,
                                                       err)
                    })

                    if isValid {
                        return swap
                    } else {
                        throw MuunError(Errors.invalidSwap)
                    }
                })
        )
    }

   public func verifyLockTime(_ submarineSwap: SubmarineSwap, expirationInBlocks: Int) {
        /*
         This only applies to v1 swaps.
         Clients should check that the locktime in the funding output script for the swap is less than or equal to
         current_blockchain_height + previously_chosen_blocks_until_expiration + 2.
         The + 2 is to prevent a race condition if the server finds out about new blocks before the client.
         */
        let currentBlockchainHeight = blockchainHeightRepository.getCurrentBlockchainHeight()
        if let userLockTime = submarineSwap._fundingOutput._userLockTime {
            if currentBlockchainHeight + expirationInBlocks + 2 < userLockTime {
                Logger.fatal(
                """
                This means we have a mismatch between the client information and the server about the blockchain tip.
                Current Blockchain Height: \(currentBlockchainHeight) \
                Expiration in Blocks: \(expirationInBlocks) \
                Swap user lock time: \(userLockTime)
                """
                )
            }
        }
    }

    public func chooseExpirationTimeInBlocks(sats: Decimal) -> Int {
        // For 1-conf transactions (amount > 150_000 sats) just use 24 hours (144 blocks).
        // For 0-conf transactions scale the expiration time linearly from 1 day to 7 days.
        if sats > 150_000 {
            return 144
        }
        let value = NSDecimalNumber(decimal: 144 * (7 - 6 * sats / 150_000.0))
        return Int(truncating: value)
    }

    enum Errors: Error {
        case invalidSwap
    }

}
