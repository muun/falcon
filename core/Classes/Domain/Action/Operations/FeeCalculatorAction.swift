//
//  FeeCalculatorAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct FeeInfo {
    public let feeCalculator: FeeCalculator
    public let feeWindow: FeeWindow
    public let exchangeRateWindow: ExchangeRateWindow
}

public class FeeCalculatorAction: AsyncAction<FeeInfo> {

    private let realTimeDataAction: RealTimeDataAction
    private let nextTransactionSizeRepository: NextTransactionSizeRepository

    init(realTimeDataAction: RealTimeDataAction, nextTransactionSizeRepository: NextTransactionSizeRepository) {
        self.realTimeDataAction = realTimeDataAction
        self.nextTransactionSizeRepository = nextTransactionSizeRepository

        super.init(name: "FeeCalculatorAction")
    }

    public func run(isSwap: Bool) {

        let single = realTimeDataAction.getValue()
            .map({ data -> FeeInfo in
                // FIXME: This should consume some action to get the next transaction size
                let calculator = FeeCalculator(
                    targetedFees: data.feeWindow.targetedFees,
                    nts: self.nextTransactionSizeRepository.getNextTransactionSize()!
                )

                return FeeInfo(feeCalculator: calculator,
                                           feeWindow: data.feeWindow,
                                           exchangeRateWindow: data.exchangeRateWindow)
            })

        runSingle(single)
        // We need to have the latest realTimeData before paying a swap
        realTimeDataAction.run(forceUpdate: isSwap)
    }
}
