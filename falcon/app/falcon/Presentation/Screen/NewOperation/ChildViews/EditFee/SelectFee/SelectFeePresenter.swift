//
//  SelectFeePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation


enum SelectFeeSection {
    case title
    case targetedFees(targets: [UInt])
    case enterManually
}

class SelectFeePresenter<Delegate: BasePresenterDelegate>: FeeEditorPresenter<Delegate> {

    struct FeeData {
        let fee: FeeState
        let targetBlock: UInt
    }

    lazy var feesData: [FeeData] = calculateFeesData()

    var sections: [SelectFeeSection] {
        return [.title, .targetedFees(targets: allTargetBlocks), .enterManually]
    }

    private var allTargetBlocks: [UInt] {
        return [feeConfirmationTargets.fast,
                feeConfirmationTargets.medium,
                feeConfirmationTargets.slow]
    }

    func numberOfRowsForSection(_ section: Int) -> Int {
        switch sections[section] {
        case .title: return 1
        case .targetedFees: return feesData.count
        case .enterManually: return 1
        }
    }

    private func calculateFeesData() -> [FeeData] {
        var allFeesData: [FeeData] = [FeeData]()
        for target in allTargetBlocks {
            let rate = minFeeRate(target)
            let fee = calculateFee(rate).adapt()
            // To avoid duplicated values, only different fee / target blocks will be presented to users.
            if !allFeesData.contains(where: { $0.fee == fee }) {
                let feeData = FeeData(fee: fee, targetBlock: target)
                allFeesData.append(feeData)
            }
        }
        return allFeesData
    }

    func fee(for indexPath: IndexPath) -> FeeState {
        return feesData[indexPath.row].fee
    }

    func timeText(for indexPath: IndexPath) -> String {
        switch sections[indexPath.section] {
        case .targetedFees:
            let block = feesData[indexPath.row].targetBlock
            return timeToConfirm(targetBlock: block)
        default:
            Logger.fatal("Only targeted fee section can call this method")
        }
    }
}
