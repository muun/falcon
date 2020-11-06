//
//  IncomingSwapRepository.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation
import GRDB
import RxSwift

class IncomingSwapRepository: BaseDatabaseRepository<IncomingSwapDB, IncomingSwap> {

    override func write(objects: [IncomingSwap]) -> Completable {
        let writeHtlcs = Completable.deferred({
            try self.coordinator.queue.write { (db) in
                for swap in objects {
                    try IncomingSwapHtlcDB(from: swap.htlc, swap: swap).save(db)
                }
            }

            return Completable.empty()
        })

        return super.write(objects: objects)
            .andThen(writeHtlcs)
    }

}
