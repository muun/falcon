//
//  GetEncryptedUserKey.swift
//  core
//
//  Created by Juan Pablo Civile on 03/09/2019.
//

import Foundation
import RxSwift
import Libwallet

public class EncryptedUserKeySelector: BaseSelector<String> {

    init(keysRepository: KeysRepository) {
        super.init({
            do {
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

                return Observable.just(encryptedKey)
            } catch {
                return Observable.error(error)
            }
        })
    }

}
