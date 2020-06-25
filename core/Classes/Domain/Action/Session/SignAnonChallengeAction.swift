//
//  SignAnonChallengeAction.swift
//  core
//
//  Created by Manu Herrera on 01/05/2020.
//

import Foundation
import RxSwift
import Libwallet

public class SignAnonChallengeAction: AsyncAction<()> {

    private let keysRepository: KeysRepository

    init(keysRepository: KeysRepository) {
        self.keysRepository = keysRepository

        super.init(name: "SignAnonChallengeAction")
    }

    func sign(_ challenge: Challenge) throws -> ChallengeSignature {
        precondition(challenge.type == .ANON)

        let anonSecret = try keysRepository.getAnonSecret()
        let challengePrivateKey = LibwalletChallengePrivateKey(Data(hex: anonSecret),
                                                               salt: Data(hex: challenge.salt))!
        let signature = try challengePrivateKey.signSha(Data(hex: challenge.challenge))
        return ChallengeSignature(type: challenge.type, hex: signature.toHexString())
    }

}
