//
//  FetchSwapServerKeyAction.swift
//  Created by Federico Bond on 25/11/2020.
//

import Foundation

public class FetchSwapServerKeyAction {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository, houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
    }

    public func run() throws {
        let publicKey = try keysRepository.getBasePublicKey()

        let publicKeySet = try houstonService.updatePublicKeySet(publicKey: publicKey)
            .toBlocking()
            .single()

        if let swapServerKey = publicKeySet.baseSwapServerPublicKey {
            keysRepository.store(swapServerKey: swapServerKey)
        } else {
            throw MuunError(Errors.noKey)
        }
    }

    enum Errors: Error {
        case noKey
    }
}
