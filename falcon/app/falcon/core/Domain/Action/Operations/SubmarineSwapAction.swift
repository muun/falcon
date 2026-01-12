//
//  SubmarineSwapAction.swift
//  falcon
//
//  Created by Manu Herrera on 05/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public class SubmarineSwapAction: AsyncAction<SubmarineSwapCreated> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let blockchainHeightRepository: BlockchainHeightRepository
    private let backgroundTimesProcessor: BackgroundTimesProcessor

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         blockchainHeightRepository: BlockchainHeightRepository,
         backgroundTimesProcessor: BackgroundTimesProcessor) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.blockchainHeightRepository = blockchainHeightRepository
        self.backgroundTimesProcessor = backgroundTimesProcessor

        super.init(name: "SubmarineSwapAction")
    }

    public func run(invoice: String, origin: String) {
        // We used to care a lot about this number for v1 swaps since it was the refund time
        // With swaps v2 we have collaborative refunds so we don't quite care and go for the max time
        let swapExpirationInBlocks = 144 * 7
        let submarineSwapRequest = SubmarineSwapRequest(invoice: invoice,
                                                        swapExpirationInBlocks: swapExpirationInBlocks,
                                                        origin: origin, 
                                                        bkgTimes: backgroundTimesProcessor.retrieveTimeLapses())
        runSingle(
            houstonService.createSubmarineSwap(submarineSwapRequest: submarineSwapRequest)
                .map({ swapCreated in

                    let userKey = try self.keysRepository.getBasePublicKey()
                    let muunKey = try self.keysRepository.getCosigningKey()

                    _ = try doWithError({ err in
                        LibwalletValidateSubmarineSwap(
                            invoice,
                            userKey.key,
                            muunKey.key,
                            swapCreated.swap,
                            Int64(swapExpirationInBlocks),
                            Environment.current.network,
                            err
                        )
                    })

                    self.verifyLockTime(swapCreated.swap, expirationInBlocks: swapExpirationInBlocks)

                    return swapCreated
                })
        )
    }

   func verifyLockTime(_ submarineSwap: SubmarineSwap, expirationInBlocks: Int) {
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

}
