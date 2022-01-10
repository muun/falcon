//
//  FeeEditorPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 15/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core
import Libwallet

typealias FeeEditorState = NewOpData.FeeEditor

class FeeEditorPresenter<Delegate: BasePresenterDelegate>: BasePresenter<Delegate> {

    let feeState: FeeState
    let calculateFee: (FeeRate) -> NewopFeeState
    let amount: Satoshis
    let takeFeeFromAmount: Bool
    let minMempoolFeeRate: FeeRate
    let minFeeRate: (_ target: UInt) -> FeeRate
    let maxFeeRate: FeeRate
    let feeConfirmationTargets: FeeConfirmationTargets

    init(delegate: Delegate, state: FeeEditorState) {
        self.feeState = state.feeState
        self.calculateFee = state.calculateFee
        self.amount = state.amount.inSatoshis
        self.takeFeeFromAmount = state.takeFeeFromAmount
        self.minMempoolFeeRate = state.minMempoolFeeRate
        self.minFeeRate = state.minFeeRate
        self.maxFeeRate = state.maxFeeRate
        self.feeConfirmationTargets = state.feeConfirmationTargets

        super.init(delegate: delegate)
    }

    func timeToConfirm(_ feeState: NewopFeeState) -> String {
        var targetBlock: UInt? = UInt(feeState.targetBlocks)
        if targetBlock == 0 {
            targetBlock = nil
        }
        return timeToConfirm(targetBlock: targetBlock)
    }

    func timeToConfirm(targetBlock: UInt?) -> String {
        if let targetBlock = targetBlock {
            return BlockHelper.timeFor(targetBlock)
        }
        // This scenario is very unlikely, but in this case we will display: "Less than 15 days"
        return L10n.FeeEditorPresenter.s1
    }

}
