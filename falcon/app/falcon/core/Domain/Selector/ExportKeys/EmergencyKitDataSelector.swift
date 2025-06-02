//
//  EmergencyKitDataSelector.swift
//  Created by Federico Bond on 08/12/2020.
//

import Foundation
import RxSwift

public struct EmergencyKitData {
    public let userKey: String
    public let userFingerprint: String
    public let muunKey: String
    public let muunFingerprint: String
    public let rcChecksum: String
}

public class EmergencyKitDataSelector: BaseOptionalSelector<EmergencyKitData> {

    init(keysRepository: KeysRepository) {
        super.init({
            do {
                let muunKey = try keysRepository.getMuunPrivateKey()

                let privateKey = try keysRepository.getBasePrivateKey()
                let challengeKey = try keysRepository.getChallengeKey(with: .RECOVERY_CODE)

                let encryptedKey = try Self.getOrCreateEncriptedUserPrivateKey(keysRepository: keysRepository,
                                                                               challengeKey: challengeKey,
                                                                               privateKey: privateKey,
                                                                               muunPrivateKey: muunKey)

                let rcChecksum = try challengeKey.getChecksum()

                let data = EmergencyKitData(
                    userKey: encryptedKey,
                    userFingerprint: try keysRepository.getUserKeyFingerprint(),
                    muunKey: muunKey,
                    muunFingerprint: try keysRepository.getMuunKeyFingerprint(),
                    rcChecksum: rcChecksum
                )

                return Observable.just(data)
            } catch {
                return Observable.error(error)
            }
        })
    }
    
    // Avoid user private key rotation on emergency kit. 
    private static func getOrCreateEncriptedUserPrivateKey(keysRepository: KeysRepository,
                                                           challengeKey: ChallengeKey,
                                                           privateKey: WalletPrivateKey,
                                                           muunPrivateKey: String) throws -> String {
        do {
            let storedEncriptedPrivateKey = try keysRepository.getEncriptedUserPrivateKey()
            return storedEncriptedPrivateKey
        } catch where error.isKindOf(KeyStorageError.missingKey) {
            let newEncriptedPrivateKey = try challengeKey.encryptKey(privateKey,
                                                                     muunPrivateKey: muunPrivateKey)
            try keysRepository.store(encriptedUserPrivateKey: newEncriptedPrivateKey)

            return newEncriptedPrivateKey
        } catch {
            Logger.log(.err, error.localizedDescription)
            // Something happened and I need the UI to show an error withouth exposing the keychain
            // data errors
            throw MuunError(DomainError.emergencyKitExportError)
        }
    }
}
