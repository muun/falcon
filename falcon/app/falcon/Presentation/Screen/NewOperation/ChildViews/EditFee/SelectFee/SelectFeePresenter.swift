//
//  SelectFeePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

enum SelectFeeSection {
    case title
    case targetedFees(targets: [UInt])
    case enterManually
}

class SelectFeePresenter<Delegate: BasePresenterDelegate>: FeeEditorPresenter<Delegate> {

    lazy var fees: [FeeState] = calculateFees()
    var targetBlocks: [UInt] {
        return [feeConfirmationTargets.fast, feeConfirmationTargets.medium, feeConfirmationTargets.slow]
    }

    var sections: [SelectFeeSection] {
        return [.title, .targetedFees(targets: targetBlocks), .enterManually]
    }

    func numberOfRowsForSection(_ section: Int) -> Int {
        switch sections[section] {
        case .title: return 1
        case .targetedFees: return fees.count
        case .enterManually: return 1
        }
    }

    private func calculateFees() -> [FeeState] {
        var allFees: [FeeState] = [FeeState]()
        for target in targetBlocks {
            let rate = minFeeRate(target)
            let fee = calculateFee(rate).adapt()
            // Do not add duplicate values
            if !allFees.contains(fee) {
                allFees.append(fee)
            }
        }
        return allFees
    }

    func fee(for indexPath: IndexPath) -> FeeState {
        return fees[indexPath.row]
    }

    func timeText(for indexPath: IndexPath) -> String {
        switch sections[indexPath.section] {
        case .targetedFees:
            let block = targetBlocks[indexPath.row]
            return timeToConfirm(targetBlock: block)
        default:
            Logger.fatal("Only targeted fee section can call this method")
        }
    }
}
