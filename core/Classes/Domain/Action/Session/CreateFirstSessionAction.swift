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
    private let setupChallengeAction: SetupChallengeAction
    private let logoutAction: LogoutAction
    private let houstonService: HoustonService

    init(keysRepository: KeysRepository,
         userRepository: UserRepository,
         setupChallengeAction: SetupChallengeAction,
         logoutAction: LogoutAction,
         houstonService: HoustonService) {
        self.keysRepository = keysRepository
        self.userRepository = userRepository
        self.setupChallengeAction = setupChallengeAction
        self.logoutAction = logoutAction
        self.houstonService = houstonService

        super.init(name: "CreateFirstSessionAction")
    }

    public func run(gcmToken: String) throws {
        // We have to wipe everything to avoid edgy bugs with the notifications
        logoutAction.run(notifyHouston: false)

        let single = logoutAction.getValue()
            .catchErrorJustReturn(()) // If logout fails, it's all cool
            .flatMap { _ in
                try self.createFirstSession(gcmToken: gcmToken)
            }

        runSingle(single)
    }

    private func createFirstSessionModel(type: ChallengeType,
                                         challengePublicKey: String,
                                         userInput: String,
                                         salt: [UInt8],
                                         gcmToken: String) throws -> CreateFirstSession {

        let challengeSetup = try setupChallengeAction.buildChallengeSetup(type: type,
                                                                          challengePublicKey: challengePublicKey,
                                                                          userInput: userInput,
                                                                          salt: salt)

        let client = Client(buildType: Environment.current.buildType, version: Int(core.Constant.buildVersion)!)
        return CreateFirstSession(client: client,
                                  gcmToken: gcmToken,
                                  primaryCurrency: Locale.current.currencyCode ?? "USD",
                                  basePublicKey: try keysRepository.getBasePublicKey(),
                                  anonChallengeSetup: challengeSetup)
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

    public func createFirstSession(gcmToken: String) throws -> Single<CreateFirstSessionOk> {

        let salt = Data(Hashes.randomBytes(count: 8))
        let anonSecret = Data(Hashes.randomBytes(count: 32))
        let anonSecretHex = anonSecret.toHexString()
        let challengeKey = LibwalletChallengePrivateKey(anonSecret, salt: salt)!
        let challengePubKeyHex = challengeKey.pubKeyHex()

        createBasePrivateKey()

        let challengeKeyModel = ChallengeKey(type: .ANON,
                                             publicKey: Data(hex: challengePubKeyHex),
                                             salt: salt)
        try keysRepository.store(challengeKey: challengeKeyModel, type: .ANON)
        try keysRepository.store(anonSecret: anonSecretHex)

        return Single.deferred({
            Single.just(try self.createFirstSessionModel(type: .ANON,
                                                         challengePublicKey: challengePubKeyHex,
                                                         userInput: anonSecretHex,
                                                         salt: salt.bytes,
                                                         gcmToken: gcmToken)
            )})
            .flatMap({
                self.houstonService.createFirstSession(firstSession: $0)
            })
            .do(onSuccess: { response in
                self.userRepository.setUser(response.user)
                self.keysRepository.store(cosigningKey: response.cosigningPublicKey)
            })
    }
}
