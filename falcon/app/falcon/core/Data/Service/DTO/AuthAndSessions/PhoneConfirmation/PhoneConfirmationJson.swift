//
//  PhoneConfirmation.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct PhoneConfirmationJson: Codable {

    let verificationCode: String
    let signedUp: Bool?
    let hasPasswordChallengeKey: Bool?
    let hasRecoveryCodeChallengeKey: Bool?

}
