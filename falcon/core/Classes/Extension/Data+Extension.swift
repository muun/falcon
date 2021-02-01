//
//  Data+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 13/09/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

extension Data {

    public init(hex: String) {
        self.init([UInt8](hex: hex))
    }

    public var bytes: [UInt8] {
        return Array(self)
    }

    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)

    public func toHexString() -> String {
        return String(reduce(into: "".unicodeScalars) { result, value in
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
        })
    }

}
