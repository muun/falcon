//
//  PreloadFeeDataAction.swift
//  core-all
//
//  Created by Daniel Mankowski on 30/08/2024.
//

import RxSwift

public class PreloadFeeDataAction: AsyncAction<()>, Runnable {

    public let refreshIntervalInSeconds: Int = 60

    private var lastSyncTime: Date = .distantPast

    private let houstonService: HoustonService
    private let feeWindowRepository: FeeWindowRepository
    private let minFeeRateRepository: MinFeeRateRepository
    private let nextTransactionSizeRepository: NextTransactionSizeRepository
    private let featureFlagsRepository: FeatureFlagsRepository
    private let libwalletService: LibwalletService
    private let throttleInterval: TimeInterval = {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return 0.3
        }
        #endif
        return 10
    }()

    init(houstonService: HoustonService,
         feeWindowRepository: FeeWindowRepository,
         minFeeRateRepository: MinFeeRateRepository,
         nextTransactionSizeRepository: NextTransactionSizeRepository,
         featureFlagsRepository: FeatureFlagsRepository,
         libwalletService: LibwalletService) {

        self.houstonService = houstonService
        self.feeWindowRepository = feeWindowRepository
        self.minFeeRateRepository = minFeeRateRepository
        self.nextTransactionSizeRepository = nextTransactionSizeRepository
        self.featureFlagsRepository = featureFlagsRepository
        self.libwalletService = libwalletService

        super.init(name: "PreloadFeeDataAction")
    }

    /**
     Runned from TaskRunner.
     */
    public func run() {
        guard shouldUpdateData() else { return }

        refreshFeeData(refreshPolicy: .periodic)
    }

    public func run(refreshPolicy: FeeBumpRefreshPolicy) {
        guard shouldUpdateData() else { return }

        refreshFeeData(refreshPolicy: refreshPolicy)
    }

    public func forceRun(refreshPolicy: FeeBumpRefreshPolicy) {
        refreshFeeData(refreshPolicy: refreshPolicy)
    }

    private func refreshFeeData(refreshPolicy: FeeBumpRefreshPolicy) {
        // Fee Data only should be updated in foreground.
        guard DeviceUtils.appState == .active else { return }
        guard featureFlagsRepository.fetch().contains(.effectiveFeesCalculation) else { return }
        if let request = makeRealTimeFeeRequest(refreshPolicy: refreshPolicy) {
            runCompletable(fetchRealTimeFees(realTimeFeesRequest: request,
                                             refreshPolicy: refreshPolicy))
        } else {
            // If there are no unconfirmed UTXOs, it means there are no fee bump functions.
            // Remove the fee bump functions by storing an empty list.
            let emptyFeeBumpFunctions = FeeBumpFunctions(uuid: "", functions: [String]())
            libwalletService.persistFeeBumpFunctions(feeBumpFunctions: emptyFeeBumpFunctions,
                                                     refreshPolicy: refreshPolicy)
        }
    }

    private func fetchRealTimeFees(realTimeFeesRequest: RealTimeFeesRequestJson,
                                   refreshPolicy: FeeBumpRefreshPolicy) -> Completable {

        return houstonService.fetchRealTimeFees(realTimeFeesRequest: realTimeFeesRequest)
            .do(onSuccess: { [weak self] (data) in
                self?.feeWindowRepository.setFeeWindow(data.feeWindow)
                let minMempoolFeeRateInSatsPerWeightUnit = data.minMempoolFeeRateInSatPerVbyte / 4
                self?.minFeeRateRepository
                    .store(satsPerWeightUnit: minMempoolFeeRateInSatsPerWeightUnit)
                self?.libwalletService
                    .persistFeeBumpFunctions(feeBumpFunctions: data.feeBumpFunctions,
                                             refreshPolicy: refreshPolicy)
                self?.lastSyncTime = Date()
            })
            .asCompletable()
    }

    private func makeRealTimeFeeRequest(refreshPolicy: FeeBumpRefreshPolicy) -> RealTimeFeesRequestJson? {
        let unconfirmedUtxos = nextTransactionSizeRepository
            .getNextTransactionSize()?
            .sizeProgression
            .compactMap {
                if $0.utxoStatus == .UNCONFIRMED {
                    return $0.outpoint
                }
                return nil
            }

        guard let unconfirmedUtxos else { return nil }

        return RealTimeFeesRequestJson(unconfirmedOutpoints: unconfirmedUtxos,
                                       feeBumpRefreshPolicy: refreshPolicy.toJson())
    }

    private func shouldUpdateData() -> Bool {
        Date().timeIntervalSince(lastSyncTime) >= throttleInterval
    }
}
