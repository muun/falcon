//
//  EmergencyKitDataSelector.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 08/12/2020.
//

import Foundation
import RxSwift
import Libwallet

public struct EmergencyKitData {
    public let userKey: String
    public let userFingerprint: String
    public let muunKey: String
    public let muunFingerprint: String
}

public class EmergencyKitDataSelector: BaseOptionalSelector<EmergencyKitData> {

    init(keysRepository: KeysRepository) {
        super.init({
            do {
                let muunKey = try keysRepository.getMuunPrivateKey()

                let privateKey = try keysRepository.getBasePrivateKey()
                let rawChallengeKey = try keysRepository.getChallengeKey(with: .RECOVERY_CODE)

                let challengePublicKey = try doWithError({ error in
                    LibwalletNewChallengePublicKeyFromSerialized(rawChallengeKey.publicKey, error)
                })

                let encryptedKey = try doWithError({ error in
                    challengePublicKey.encryptKey(privateKey.key,
                                                  recoveryCodeSalt: rawChallengeKey.salt,
                                                  birthday: 0xFFFF, // The birthday for the user key isn't used
                                                  error: error)
                })

                let data = EmergencyKitData(
                    userKey: encryptedKey,
                    userFingerprint: try keysRepository.getUserKeyFingerprint(),
                    muunKey: muunKey,
                    muunFingerprint: try keysRepository.getMuunKeyFingerprint()
                )

                return Observable.just(data)
            } catch {
                return Observable.error(error)
            }
        })
    }

}
