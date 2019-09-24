//
//  Integrity.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct IntegrityCheck {
    let publicKeySet: PublicKeySet
    let balanceInSatoshis: Double
}

struct IntegrityStatus {
    let isBasePublicKeyOk: Bool
    let isExternalMaxUsedIndexOk: Bool
    let isBalanceOk: Bool
}
