//
//  PasswordSetupJson.swift
//
//  Created by Manu Herrera on 29/04/2020.
//

import Foundation

struct PasswordSetupJson: Codable {

    let challengeSignature: ChallengeSignatureJson
    let challengeSetup: ChallengeSetupJson

}
