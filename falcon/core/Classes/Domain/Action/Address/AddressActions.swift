//
//  AddressActions.swift
//  falcon
//
//  Created by Juan Pablo Civile on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift
import Libwallet

public class AddressActions {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    private let syncExternalAddresses: SyncExternalAddresses
    private let externalAddressWatchWindowSize: Int = 15

    init(houstonService: HoustonService,
         keysRepository: KeysRepository,
         syncExternalAddresses: SyncExternalAddresses) {

        self.houstonService = houstonService
        self.keysRepository = keysRepository
        self.syncExternalAddresses = syncExternalAddresses
    }

    func syncPublicKeySet() -> Completable {

        return Single.deferred { () throws -> Single<PublicKeySet> in
                let publicKey = try self.keysRepository.getBasePublicKey()
                return self.houstonService.updatePublicKeySet(publicKey: publicKey)
            }
            .do(onSuccess: { (keySet) in

                if let indices = keySet.externalPublicKeyIndices {
                    self.keysRepository.updateMaxUsedIndex(indices.maxUsedIndex)

                    if let maxWatchIndex = indices.maxWatchingIndex {
                        self.keysRepository.updateMaxWatchingIndex(maxWatchIndex)
                    }
                }

                if let muunPublicKey = keySet.baseCosigningPublicKey {
                    self.keysRepository.store(cosigningKey: muunPublicKey)
                }
                if let swapServerPublicKey = keySet.baseSwapServerPublicKey {
                    self.keysRepository.store(swapServerKey: swapServerPublicKey)
                }

            })
            .asCompletable()
    }

    public func generateExternalAddresses() throws -> (segwit: String, legacy: String) {

        let maxUsedIndex = keysRepository.getMaxUsedIndex()
        let maxWatchingIndex = keysRepository.getMaxWatchingIndex()

        let nextIndex: Int
        if maxUsedIndex < 0 {
            nextIndex = 0
        } else if maxUsedIndex < maxWatchingIndex {
            nextIndex = maxUsedIndex + 1
        } else {
            // This means the user is deriving addresses offline, so we take a random one from the last address
            // window because the server is watching them all 👀.
            let minWatchIndex = max(maxWatchingIndex - externalAddressWatchWindowSize, 0)
            nextIndex = Int.random(in: minWatchIndex ..< maxWatchingIndex)
        }

        let derivedMuunKey = try keysRepository.getCosigningKey()
            .derive(to: .external)
            .derive(at: UInt32(nextIndex))

        let derivedKey = try keysRepository.getBasePublicKey()
            .derive(to: .external)
            .derive(at: UInt32(nextIndex))

        let segwitAddress = try doWithError { error in
            LibwalletCreateAddressV4(derivedKey.key, derivedMuunKey.key, error)
        }

        let legacyAddress = try doWithError { error in
            LibwalletCreateAddressV3(derivedKey.key, derivedMuunKey.key, error)
        }

        if nextIndex > maxUsedIndex {
            keysRepository.updateMaxUsedIndex(nextIndex)

            syncExternalAddresses.run()
        }

        return (segwitAddress.address(), legacyAddress.address())
    }
}
