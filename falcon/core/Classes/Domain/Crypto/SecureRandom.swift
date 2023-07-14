//
//  SecureRandom.swift
//  falcon
//
//  Created by Manu Herrera on 05/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

public enum SecureRandom {

    public static func randomBytes(count: Int) -> Data {

        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if status != errSecSuccess {
            fatalError()
        }

        return Data(bytes)

    }

}
