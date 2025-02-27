//
//  StartEmailSetupJson.swift
//
//  Created by Manu Herrera on 28/04/2020.
//

struct StartEmailSetupJson: Codable {

    let email: String
    let challengeSignature: ChallengeSignatureJson

}
