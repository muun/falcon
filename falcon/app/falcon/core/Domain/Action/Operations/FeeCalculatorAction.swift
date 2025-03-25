//
//  FeeCalculatorAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct FeeInfo {
    public let nextTransactionSize: NextTransactionSize
    public let feeWindow: FeeWindow
    public let minFeeRateInSatsPerVByte: Double
    public let exchangeRateWindow: ExchangeRateWindow
}

public class FeeCalculatorAction: AsyncAction<FeeInfo> {

    private let realTimeDataAction: RealTimeDataAction
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let minFeeRateRepository: MinFeeRateRepository

    init(realTimeDataAction: RealTimeDataAction,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         minFeeRateRepository: MinFeeRateRepository) {

        self.realTimeDataAction = realTimeDataAction
        self.nextTransactionSizeRepository = nextTransactionSizeRepository
        self.minFeeRateRepository = minFeeRateRepository

        super.init(name: "FeeCalculatorAction")
    }

    public func run(isSwap: Bool) {

        let single = realTimeDataAction.getValue()
            .map({ data -> FeeInfo in
                let nts = self.nextTransactionSizeRepository.getNextTransactionSize()!
                let minFeeRate = (self.minFeeRateRepository.fetch().satsPerVByte as NSDecimalNumber)
                    .doubleValue

                return FeeInfo(nextTransactionSize: nts,
                               feeWindow: data.feeWindow,
                               minFeeRateInSatsPerVByte: minFeeRate,
                               exchangeRateWindow: data.exchangeRateWindow)
            })

        runSingle(single)
        // We need to have the latest realTimeData before paying a swap
        realTimeDataAction.run(forceUpdate: isSwap)
    }
}
