//
//  MigrateFingerprintsAction.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 15/12/2020.
//

import RxSwift

public class MigrateFingerprintsAction {

    private let keysRepository: KeysRepository
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository, houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.houstonService = houstonService
    }

    public func run() throws {
        _ = try Single.zip(
            getUserKeyFingerprint(),
            getMuunKeyFingerprint()
        ).do(onSuccess: {
            self.keysRepository.store(userKeyFingerprint: $0)
            self.keysRepository.store(muunKeyFingerprint: $1)
        }).toBlocking().first()
    }

    fileprivate func getMuunKeyFingerprint() -> Single<String> {
        return houstonService.fetchMuunKeyFingerprint()
    }

    fileprivate func getUserKeyFingerprint() -> Single<String> {
        return Single<WalletPublicKey>.deferred {
            let basePublicKey = try self.keysRepository.getBasePublicKey()
            return Single.just(basePublicKey)
        }.map { $0.fingerprint.toHexString() }
    }
}
