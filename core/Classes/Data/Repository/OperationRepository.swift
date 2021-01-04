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

class OperationRepository: BaseDatabaseRepository<OperationDB, Operation> {

    private let publicProfileRepository: PublicProfileRepository
    private let submarineSwapRepository: SubmarineSwapRepository
    private let incomingSwapRepository: IncomingSwapRepository

    init(coordinator: DatabaseCoordinator,
         publicProfileRepository: PublicProfileRepository,
         submarineSwapRepository: SubmarineSwapRepository,
         incomingSwapRepository: IncomingSwapRepository) {
        self.publicProfileRepository = publicProfileRepository
        self.submarineSwapRepository = submarineSwapRepository
        self.incomingSwapRepository = incomingSwapRepository

        super.init(coordinator: coordinator)
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

    func watchOperations() -> Observable<[Operation]> {
        return watchObjects()
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

        if count(query: pendingQuery) > 0 {
            return .pending
        }

        return .confirmed
    }
}

extension OperationStatus: DatabaseValueConvertible {}

extension OperationDirection: DatabaseValueConvertible {}
