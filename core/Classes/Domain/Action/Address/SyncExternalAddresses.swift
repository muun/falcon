//
//  SyncExternalAddresses.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

public class SyncExternalAddresses: AsyncAction<()>, Runnable {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository, houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService

        super.init(name: "GenerateExternalAddressAction")
    }

    public func run() {

        let completable = Single.deferred { () -> Single<ExternalAddressesRecord> in
                let maxUsedIndex = self.keysRepository.getMaxUsedIndex()
                let newRecord = ExternalAddressesRecord(maxUsedIndex: maxUsedIndex, maxWatchingIndex: nil)
                return self.houstonService.update(externalAddressesRecord: newRecord)
            }.do(onSuccess: { newIndexes in
                if let maxWatchIndex = newIndexes.maxWatchingIndex {
                    self.keysRepository.updateMaxWatchingIndex(maxWatchIndex)
                }

                self.keysRepository.updateMaxUsedIndex(newIndexes.maxUsedIndex)
            })
            .asCompletable()

        runCompletable(completable)
    }
}
