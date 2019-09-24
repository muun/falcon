//
//  PublicKeySetJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct PublicKeySet {

    let basePublicKey: WalletPublicKey
    let baseCosigningPublicKey: WalletPublicKey?
    let externalPublicKeyIndices: ExternalAddressesRecord?

    init(basePublicKey: WalletPublicKey,
         baseCosigningPublicKey: WalletPublicKey?,
         externalPublicKeyIndices: ExternalAddressesRecord?) {
        self.basePublicKey = basePublicKey
        self.baseCosigningPublicKey = baseCosigningPublicKey
        self.externalPublicKeyIndices = externalPublicKeyIndices
    }

    init(basePublicKey: WalletPublicKey) {
        self.init(basePublicKey: basePublicKey,
                  baseCosigningPublicKey: nil,
                  externalPublicKeyIndices: nil)
    }
}

struct ExternalAddressesRecord {
    let maxUsedIndex: Int
    let maxWatchingIndex: Int?
}
