//
//  PublicKeySetJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct PublicKeySetJson: Codable {

    let basePublicKey: PublicKeyJson
    let baseCosigningPublicKey: PublicKeyJson?
    let externalPublicKeyIndices: ExternalAddressesRecordJson?

}

struct PublicKeyJson: Codable {
    let key: String
    let path: String
}

struct ExternalAddressesRecordJson: Codable {
    let maxUsedIndex: Int
    let maxWatchingIndex: Int?
}

struct FeedbackJson: Codable {
    let content: String
}
