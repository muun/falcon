//
//  KeyCrypter.swift
//  falcon
//
//  Created by Manu Herrera on 13/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet

class KeyCrypter {

    static func encrypt(_ walletPrivateKey: WalletPrivateKey, passphrase: String) -> String {

        do {
            return try doWithError({ error in
                LibwalletKeyEncrypt(walletPrivateKey.key, passphrase, error)
            })
        } catch {
            Logger.fatal(error: error)
        }
    }

    static func decrypt(_ value: String, passphrase: String) throws -> WalletPrivateKey {

        let decrypted = try doWithError({ error in
            LibwalletKeyDecrypt(value, passphrase, Environment.current.network, error)
        })

        return WalletPrivateKey(decrypted.key!)
    }

}
