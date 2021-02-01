//
//  OperationRepository.swift
//  falcon
//
//  Created by Manu Herrera on 06/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift
import GRDB

public enum OperationsState {
    case confirmed
    case pending
    case cancelable
}

public struct OperationsChange {
    public let numberOfOperations: Int
    public let lastOperation: Operation?
}

class OperationRepository: BaseDatabaseRepository<OperationDB, Operation> {

    private let publicProfileRepository: PublicProfileRepository
    private let submarineSwapRepository: SubmarineSwapRepository
    private let incomingSwapRepository: IncomingSwapRepository

    init(queue: DatabaseQueue,
         publicProfileRepository: PublicProfileRepository,
         submarineSwapRepository: SubmarineSwapRepository,
         incomingSwapRepository: IncomingSwapRepository) {
        self.publicProfileRepository = publicProfileRepository
        self.submarineSwapRepository = submarineSwapRepository
        self.incomingSwapRepository = incomingSwapRepository

        super.init(queue: queue)
    }

    func storeOperations(_ operations: [Operation]) -> Completable {
        var profiles: [PublicProfile] = []
        var submarineSwaps: [SubmarineSwap] = []
        var incomingSwaps: [IncomingSwap] = []

        for op in operations {
            if let senderProfile = op.senderProfile {
                profiles.append(senderProfile)
            }

            if let receiverProfile = op.receiverProfile {
                profiles.append(receiverProfile)
            }

            if let submarineSwap = op.submarineSwap {
                submarineSwaps.append(submarineSwap)
            }

            if let incomingSwap = op.incomingSwap {
                incomingSwaps.append(incomingSwap)
            }
        }

        return incomingSwapRepository.write(objects: incomingSwaps)
            .andThen(submarineSwapRepository.write(objects: submarineSwaps))
            .andThen(publicProfileRepository.write(objects: profiles))
            .andThen(write(objects: operations))
    }

    func watchOperationsChange() -> Observable<OperationsChange> {

        return ValueObservation.tracking(OperationDB.all()) { db in
            let numberOfOperations = try OperationDB.fetchCount(db)
            let lastOperation = try OperationDB
                .order(Column("creationDate").desc)
                .limit(1)
                .fetchOne(db)?
                .to(using: db)

            return OperationsChange(
                numberOfOperations: numberOfOperations,
                lastOperation: lastOperation
            )
        }.rx.observe(in: queue)

    }

    func watchOperationsLazy() -> Observable<LazyLoadedList<Operation>> {

        return DatabaseRegionObservation(tracking: OperationDB.all())
            .rx
            .changes(in: queue)
            .map { [weak self] _ in

                guard let self = self else {
                    throw MuunError(Errors.readFailed)
                }

                let query = OperationDB.all()
                    .order(Column("creationDate").desc)

                return LazyLoadedList<Operation>(
                    total: { self.count(query: query) },
                    onLoadMore: { (limit: Int, offset: Int) in
                        return self.objects(query: query.limit(limit, offset: offset)) ?? []
                    }
                )
            }
    }

    func findByIncomingSwap(uuid: String) -> Operation? {
        return object(query: OperationDB.filter(Column("incomingSwapUuid") == uuid))
    }

    func getOperationsState() -> OperationsState {
        let pendingStates = OperationStatus.pendingStates.map { $0.rawValue }
        let incomingDirection = OperationDirection.INCOMING.rawValue

        let cancelableQuery = OperationDB
            .filter(Column("isReplaceableByFee") == true)
            .filter(pendingStates.contains(Column("status")))
            .filter(Column("direction") == incomingDirection)

        if count(query: cancelableQuery) > 0 {
            return .cancelable
        }

        let pendingQuery = OperationDB
            .filter(pendingStates.contains(Column("status")))
            .filter(Column("direction") == incomingDirection)

        if exists(query: pendingQuery) {
            return .pending
        }

        return .confirmed
    }

    func hasPendingOperations(includeUnsettled: Bool = true) -> Bool {
        var pendingStates = OperationStatus.pendingStates.map { $0.rawValue }

        if includeUnsettled {
            pendingStates.append(OperationStatus.CONFIRMED.rawValue)
        }

        let query = OperationDB
            .filter(pendingStates.contains(Column("status")))

        return exists(query: query)
    }

    func hasPendingSwaps() -> Bool {
        let query = OperationDB
            .joining(required: OperationDB.submarineSwap)
            .filter(Column("status") == OperationStatus.SWAP_PENDING.rawValue)
            .filter(Column("confirmationsNeeded").qualifiedExpression(with: TableAlias(name: "submarineSwapDB")) == 0)

        return exists(query: query)
    }

    func hasPendingIncomingSwaps() -> Bool {
        let query = OperationDB
            .joining(required: OperationDB.incomingSwap)
            .filter(Column("status") == OperationStatus.BROADCASTED.rawValue)

        return exists(query: query)
    }
}

extension OperationStatus: DatabaseValueConvertible {}

extension OperationDirection: DatabaseValueConvertible {}
