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
        self.init(bytes: [UInt8](hex: hex))
    }

    public var bytes: [UInt8] {
        return Array(self)
    }

    public func toHexString() -> String {
        return bytes.toHexString()
    }

}
