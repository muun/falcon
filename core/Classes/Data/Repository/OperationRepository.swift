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

class OperationRepository: BaseDatabaseRepository<OperationDB, Operation> {

    private let publicProfileRepository: PublicProfileRepository
    private let submarineSwapRepository: SubmarineSwapRepository

    init(coordinator: DatabaseCoordinator,
         publicProfileRepository: PublicProfileRepository,
         submarineSwapRepository: SubmarineSwapRepository) {
        self.publicProfileRepository = publicProfileRepository
        self.submarineSwapRepository = submarineSwapRepository

        super.init(coordinator: coordinator)
    }

    func storeOperations(_ operations: [Operation]) -> Completable {
        var profiles: [PublicProfile] = []
        var submarineSwaps: [SubmarineSwap] = []

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
        }

        return submarineSwapRepository.write(objects: submarineSwaps)
            .andThen(publicProfileRepository.write(objects: profiles))
            .andThen(write(objects: operations))
    }

    func watchOperations() -> Observable<[Operation]> {
        return watchObjects()
    }

}

extension OperationStatus: DatabaseValueConvertible {}

extension OperationDirection: DatabaseValueConvertible {}
