//
//  Contact.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct ContactJson: Codable {

    let publicProfile: PublicProfileJson
    let maxAddressVersion: Int
    let publicKey: PublicKeyJson
    let cosigningPublicKey: PublicKeyJson
    let lastDerivationIndex: Double

}
