//
//  FeeCalculatorAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public class FeeCalculatorAction: AsyncAction<(FeeCalculator, FeeWindow, ExchangeRateWindow)> {

    private let realTimeDataAction: RealTimeDataAction
    private let nextTransactionSizeRepository: NextTransactionSizeRepository

    init(realTimeDataAction: RealTimeDataAction, nextTransactionSizeRepository: NextTransactionSizeRepository) {
        self.realTimeDataAction = realTimeDataAction
        self.nextTransactionSizeRepository = nextTransactionSizeRepository

        super.init(name: "FeeCalculatorAction")
    }

    public func run(isSwap: Bool) {

        let single = realTimeDataAction.getValue()
            .map({ data -> (FeeCalculator, FeeWindow, ExchangeRateWindow) in
                let calculator = FeeCalculator(
                    targetedFees: data.feeWindow.targetedFees,
                    // FIXME: This should consume some action to get the next transaction size
                    sizeProgression: self.nextTransactionSizeRepository.getNextTransactionSize()!.sizeProgression
                )

                return (calculator, data.feeWindow, data.exchangeRateWindow)
            })

        runSingle(single)
        // We need to have the latest realTimeData before paying a swap
        realTimeDataAction.run(forceUpdate: isSwap)
    }
}
