//
//  FeeEditorPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 15/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

enum FeeEditor {
    struct State {
        let feeState: FeeState
        let calculateFee: CalculateFee
        let feeCalculator: FeeCalculator
        let amount: Satoshis
        let feeConfirmationTargets: FeeConfirmationTargets
    }
    typealias CalculateFee = (FeeRate) -> FeeState
}

class FeeEditorPresenter<Delegate: BasePresenterDelegate>: BasePresenter<Delegate> {

    let feeState: FeeState
    let calculateFee: FeeEditor.CalculateFee
    let feeCalculator: FeeCalculator
    let amount: Satoshis
    let feeConfirmationTargets: FeeConfirmationTargets

    init(delegate: Delegate, state: FeeEditor.State) {
        self.feeState = state.feeState
        self.calculateFee = state.calculateFee
        self.feeCalculator = state.feeCalculator
        self.amount = state.amount
        self.feeConfirmationTargets = state.feeConfirmationTargets

        super.init(delegate: delegate)
    }

    var takeFeeFromAmount: Bool {
        return feeCalculator.shouldTakeFeeFromAmount(amount)
    }

    func timeToConfirm(feeRate: FeeRate) -> String {
        return timeToConfirm(targetBlock: feeCalculator.nextHighestBlock(for: feeRate))
    }

    func timeToConfirm(targetBlock: UInt?) -> String {
        if let targetBlock = targetBlock {
            return BlockHelper.timeFor(targetBlock)
        }
        // This scenario is very unlikely, but in this case we will display: "Less than 15 days"
        return L10n.FeeEditorPresenter.s1
    }

}
