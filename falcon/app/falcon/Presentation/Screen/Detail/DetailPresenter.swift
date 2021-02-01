//
//  DetailPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 23/09/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import core
import Foundation
import Libwallet

protocol DetailPresenterDelegate: BasePresenterDelegate {}

class DetailPresenter<Delegate: DetailPresenterDelegate>: BasePresenter<Delegate> {

    private let blockchainHeightRepository: BlockchainHeightRepository

    init(delegate: Delegate, blockchainHeightRepository: BlockchainHeightRepository) {
        self.blockchainHeightRepository = blockchainHeightRepository

        super.init(delegate: delegate)
    }

    func blocksUntilRefund(ss: SubmarineSwap) -> UInt? {
        // If userLockTime - currentBlockchainHeight is greater than 0 it means the refund hasnt been completed yet
        let currentBlockchainHeight = getCurrentBlockchainHeight()
        let userLockTime = Int(ss._fundingOutput.userLockTime())

        let blocks = userLockTime - currentBlockchainHeight
        if blocks > 0 {
            return UInt(blocks)
        }

        return nil
    }

    func calculateTimeForRefund(blocksLeft: UInt) -> (time: String, blocks: String) {
        let secs = BlockHelper.timeInSecs(numBlocks: blocksLeft, certainty: 0.75)
        let hours = secs / 60 / 60
        let finalTimeString = L10n.DetailPresenter.s1(String(describing: hours))
        let finalBlocksString = L10n.DetailPresenter.s2(String(describing: blocksLeft))
        return (finalTimeString, finalBlocksString)
    }

    func getCurrentBlockchainHeight() -> Int {
        blockchainHeightRepository.getCurrentBlockchainHeight()
    }

    func getSubmarineSwapV1Version() -> Int {
        return Int(LibwalletAddressVersionSwapsV1)
    }

}
