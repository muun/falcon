//
//  CreateFirstSessionJson.swift
//  core
//
//  Created by Manu Herrera on 24/04/2020.
//

import Foundation

struct CreateFirstSessionJson: Codable {

    let client: ClientJson
    let gcmToken: String
    let primaryCurrency: String
    let basePublicKey: PublicKeyJson

}

struct CreateFirstSessionOkJson: Codable {

    let user: User
    let cosigningPublicKey: PublicKeyJson
    let swapServerPublicKey: PublicKeyJson

}

struct ClientJson: Codable {

    let type: String
    let buildType: String
    let version: Int

}
