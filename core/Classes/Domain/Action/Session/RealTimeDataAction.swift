//
//  RealTimeDataAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 20/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class RealTimeDataAction: AsyncAction<RealTimeData> {

    private let houstonService: HoustonService
    private let feeWindowRepository: FeeWindowRepository
    private let exchangeRateWindowRepository: ExchangeRateWindowRepository
    private let blockchainHeightRepository: BlockchainHeightRepository

    private let secondsForFreshData: Double = 5 * 60

    init(houstonService: HoustonService,
         feeWindowRepository: FeeWindowRepository,
         exchangeRateWindowRepository: ExchangeRateWindowRepository,
         blockchainHeightRepository: BlockchainHeightRepository) {

        self.houstonService = houstonService

        self.feeWindowRepository = feeWindowRepository
        self.exchangeRateWindowRepository = exchangeRateWindowRepository
        self.blockchainHeightRepository = blockchainHeightRepository

        super.init(name: "RealTimeDataAction")
    }

    public func run(forceUpdate: Bool = false) {
        runSingle(fetchRealTimeData(forceUpdate: forceUpdate))
    }

    private func fetchRealTimeData(forceUpdate: Bool = false) -> Single<RealTimeData> {
        if shouldUpdateData() || forceUpdate {
            return houstonService.fetchRealTimeData()
                .do(onSuccess: { (data) in
                    self.feeWindowRepository.setFeeWindow(data.feeWindow)
                    self.exchangeRateWindowRepository.setExchangeRateWindow(data.exchangeRateWindow)
                    self.blockchainHeightRepository.setBlockchainHeight(data.currentBlockchainHeight)
                })
        } else {
            let realData = RealTimeData(
                feeWindow: feeWindowRepository.getFeeWindow()!,
                exchangeRateWindow: exchangeRateWindowRepository.getExchangeRateWindow()!,
                currentBlockchainHeight: blockchainHeightRepository.getCurrentBlockchainHeight()
            )
            return Single.just(realData)
        }
    }

    private func shouldUpdateData() -> Bool {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            return true
        }
        #endif

        if let exchangeRateWindow = exchangeRateWindowRepository.getExchangeRateWindow(),
            let feeWindow = feeWindowRepository.getFeeWindow() {
            return Date().timeIntervalSince(exchangeRateWindow.fetchDate) >= secondsForFreshData
                || Date().timeIntervalSince(feeWindow.fetchDate) >= secondsForFreshData
        }
        return true
    }

}
