//
//  CreateFirstSessionAction.swift
//  core
//
//  Created by Manu Herrera on 24/04/2020.
//

import Foundation
import RxSwift
import Libwallet

public class CreateFirstSessionAction: AsyncAction<(CreateFirstSessionOk)> {

    private let keysRepository: KeysRepository
    private let userRepository: UserRepository
    private let logoutAction: LogoutAction
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository,
         userRepository: UserRepository,
         logoutAction: LogoutAction,
         houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.userRepository = userRepository
        self.logoutAction = logoutAction
        self.houstonService = houstonService

        super.init(name: "CreateFirstSessionAction")
    }

    public func run(gcmToken: String, currencyCode: String) throws {
        // We have to wipe everything to avoid edgy bugs with the notifications
        logoutAction.run(notifyHouston: false)

        let single = logoutAction.getValue()
            .catchErrorJustReturn(()) // If logout fails, it's all cool
            .flatMap { _ in
                try self.createFirstSession(gcmToken: gcmToken, currencyCode: currencyCode)
            }

        runSingle(single)
    }

    fileprivate func createBasePrivateKey() {
        let walletPrivateKey = WalletPrivateKey.createRandom()

        let baseKey: WalletPrivateKey
        do {
            baseKey = try walletPrivateKey.derive(to: .base)
            try self.keysRepository.store(key: baseKey)
        } catch {
            // Abort early if we fail to derive the key
            Logger.log(error: error)
            runSingle(Single.error(error))
        }
    }

    public func createFirstSession(gcmToken: String, currencyCode: String) throws -> Single<CreateFirstSessionOk> {

        createBasePrivateKey()

        let firstSession = CreateFirstSession(
            client: Client.buildCurrent(),
            gcmToken: gcmToken,
            primaryCurrency: currencyCode,
            basePublicKey: try keysRepository.getBasePublicKey()
        )

        return Single.deferred({
            self.houstonService.createFirstSession(firstSession: firstSession)
            })
            .do(onSuccess: { response in
                self.userRepository.setUser(response.user)
                self.keysRepository.store(cosigningKey: response.cosigningPublicKey)
                self.keysRepository.store(swapServerKey: response.swapServerPublicKey)
            })
    }
}
