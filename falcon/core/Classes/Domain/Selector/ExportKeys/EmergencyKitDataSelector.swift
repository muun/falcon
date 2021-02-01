//
//  EmergencyKitDataSelector.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 08/12/2020.
//

import Foundation
import RxSwift

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
                let challengeKey = try keysRepository.getChallengeKey(with: .RECOVERY_CODE)

                let encryptedKey = try challengeKey.encryptKey(privateKey)

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
