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
                    if let htlc = swap.htlc {
                        try IncomingSwapHtlcDB(from: htlc, swap: swap).save(db)
                    }
                }
            }

            return Completable.empty()
        })

        return super.write(objects: objects)
            .andThen(writeHtlcs)
    }

    func update(preimage: Data, for swap: IncomingSwap) -> Completable {
        return Completable.deferred {
            _ = try self.coordinator.queue.write { db in
                try IncomingSwapDB
                    .filter(Column("uuid") == swap.uuid)
                    .updateAll(db, Column("preimageHex").set(to: preimage.toHexString()))
            }

            return Completable.empty()
        }
    }

}
