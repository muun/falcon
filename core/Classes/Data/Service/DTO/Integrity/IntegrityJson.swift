//
//  Integrity.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct IntegrityCheckJson: Codable {
    let publicKeySet: PublicKeySetJson
    let balanceInSatoshis: Double
}

struct IntegrityStatusJson: Codable {
    let isBasePublicKeyOk: Bool
    let isExternalMaxUsedIndexOk: Bool
    let isBalanceOk: Bool
}
