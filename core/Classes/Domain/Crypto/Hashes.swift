//
//  Hashes.swift
//  falcon
//
//  Created by Manu Herrera on 05/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet

class Hashes {

    static func scrypt256(input: [UInt8], salt: [UInt8]) -> [UInt8] {

        return LibwalletScrypt256(Data(input), Data(salt))!.bytes
    }

    static func randomBytes(count: Int) -> [UInt8] {

        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if status != errSecSuccess {
            fatalError()
        }

        return bytes

    }

}
