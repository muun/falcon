//
//  SignChallengeWithUserKeyAction.swift
//
//  Created by Manu Herrera on 01/05/2020.
//

import Foundation
import RxSwift
import Libwallet

public class SignChallengeWithUserKeyAction: AsyncAction<()> {

    private let keysRepository: KeysRepository

    init(keysRepository: KeysRepository) {
        self.keysRepository = keysRepository

        super.init(name: "SignChallengeWithUserKeyAction")
    }

    func sign(_ challenge: Challenge) throws -> ChallengeSignature {
        precondition(challenge.type == .USER_KEY)

        let privKey = try keysRepository.getBasePrivateKey()
        let signature = try doWithError({ err in
            LibwalletSignWithPrivateKey(privKey.key, Data(hex: challenge.challenge), err)
        })

        return ChallengeSignature(type: challenge.type, hex: signature.toHexString())
    }

}
