//
//  FeeDataSyncer.swift
//  Muun
//
//  Created by Daniel Mankowski on 01/11/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import Foundation
import RxSwift

/// FeeDataSyncer handles NTS changes, observing NotificationProcessor
/// and deciding if it is necessary to refresh fee bump functions.
/// Besides, it is designed to perform only one refresh per batch of notifications
/// processed by NoticationProcessor.
class FeeDataSyncer {

    private var pendingTasks = 0 // Internal counter to track `enter` and `leave`
    private var disposeBag = DisposeBag()

    private let preloadFeeDataAction: PreloadFeeDataAction
    private let nextTransactionRepository: NextTransactionSizeRepository
    private let ntsChangesObservable: Observable<NotificationProcessingState>
    private let featureFlagsRepository: FeatureFlagsRepository

    private let dispatchGroup = DispatchGroup()

    init(preloadFeeDataAction: PreloadFeeDataAction,
         nextTransactionRepository: NextTransactionSizeRepository,
         ntsChangesObservable: Observable<NotificationProcessingState>,
         featureFlagsRepository: FeatureFlagsRepository) {
        self.preloadFeeDataAction = preloadFeeDataAction
        self.nextTransactionRepository = nextTransactionRepository
        self.ntsChangesObservable = ntsChangesObservable
        self.featureFlagsRepository = featureFlagsRepository
    }

    func appDidBecomeActive() {
        guard featureFlagsRepository.fetch().contains(.effectiveFeesCalculation)
        else { return }

        ntsChangesObservable.subscribe(onNext: { [weak self] state in
            switch state {
            case .started:
                self?.dispatchGroup.enter()

                /** The DispatchGroup executes the notify block only when the leave() calls
                 are equal to the enter() calls.
                 - Each time that enter() is called, it means that there is a pending work.
                 - Each time that leave() is called, it means that work was finished.
                 You may get confused by the pendingTasks counter; it is there because
                 if you set many times the notify(.main) it will be called as often as
                 it has been set, so we must ensure we call and set the notify only once.
                */
                if self?.pendingTasks == 0 {
                    let initialSizeProgression = self?.nextTransactionRepository
                        .getNextTransactionSize()?.sizeProgression
                    self?.dispatchGroup.notify(queue: .main) {
                        if self?.shouldUpdateBumpFunctions(from: initialSizeProgression) == true {
                            self?.preloadFeeDataAction.forceRun(refreshPolicy: .ntsChanged)
                        }
                    }
                }
                self?.pendingTasks += 1

            case .completed:
                guard let self else { return }

                // If dispatchGroup.leave() is called without a corresponding enter(),
                // the app will crash.
                if self.pendingTasks > 0 {
                    self.pendingTasks -= 1
                    self.dispatchGroup.leave()
                } else {
                    Logger.log(.err,
                               "FeeDataSyncer completed without receiving a STARTED event")
                }
            }
        }).disposed(by: disposeBag)
    }

    func appWillResignActive() {
        // Replacing disposeBag to cancel previous subscriptions
        disposeBag = DisposeBag()
    }

    private func shouldUpdateBumpFunctions(
        from initialSizeProgression: [SizeForAmount]?
    ) -> Bool {
        if let currentSizeProgression = nextTransactionRepository
            .getNextTransactionSize()?.sizeProgression {

            let newUnconfirmedUtxos = currentSizeProgression
                .filter { $0.utxoStatus == .UNCONFIRMED }
            guard !newUnconfirmedUtxos.isEmpty else { return false }

            let previousUnconfirmedUtxos = initialSizeProgression?
                .filter { $0.utxoStatus == .UNCONFIRMED }
            return newUnconfirmedUtxos != previousUnconfirmedUtxos
        }

        return false
    }
}
