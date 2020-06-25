//
//  FeeCalculatorAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct FeeCalculatorResult {
    public let feeCalculator: FeeCalculator
    public let feeWindow: FeeWindow
    public let exchangeRateWindow: ExchangeRateWindow
}

public class FeeCalculatorAction: AsyncAction<FeeCalculatorResult> {

    private let realTimeDataAction: RealTimeDataAction
    private let nextTransactionSizeRepository: NextTransactionSizeRepository

    init(realTimeDataAction: RealTimeDataAction, nextTransactionSizeRepository: NextTransactionSizeRepository) {
        self.realTimeDataAction = realTimeDataAction
        self.nextTransactionSizeRepository = nextTransactionSizeRepository

        super.init(name: "FeeCalculatorAction")
    }

    public func run(isSwap: Bool) {

        let single = realTimeDataAction.getValue()
            .map({ data -> FeeCalculatorResult in
                let nts = self.nextTransactionSizeRepository.getNextTransactionSize()!
                let calculator = FeeCalculator(
                    targetedFees: data.feeWindow.targetedFees,
                    // FIXME: This should consume some action to get the next transaction size
                    sizeProgression: nts.sizeProgression,
                    expectedDebt: nts.expectedDebt
                )

                return FeeCalculatorResult(feeCalculator: calculator,
                                           feeWindow: data.feeWindow,
                                           exchangeRateWindow: data.exchangeRateWindow)
            })

        runSingle(single)
        // We need to have the latest realTimeData before paying a swap
        realTimeDataAction.run(forceUpdate: isSwap)
    }
}
