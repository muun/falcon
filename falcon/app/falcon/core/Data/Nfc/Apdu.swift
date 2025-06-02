//
//  Apdu.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

/// Represents an APDU command.
struct APDU {
    var cls: UInt8 = 0x00
    var ins: UInt8 = 0x00
    var data: [UInt8] = []
    var p1: UInt8 = 0x00
    var p2: UInt8 = 0x00
    var appletID: String = ""   // Hex string representation of the Applet ID

    static let CLA: UInt8 = 0x00
    static let INS_SELECT: UInt8 = 0xA4

    // MARK: - Factory Method

    /// Creates a new APDU with the specified parameters.
    static func buildAPDU(cls: UInt8, ins: UInt8, data: [UInt8], p1: UInt8, p2: UInt8) -> APDU {
        return APDU(cls: cls, ins: ins, data: data, p1: p1, p2: p2)
    }

    // MARK: - APDU Message Construction

    /// Constructs the final APDU message as a byte array.
    /// The format is: [cls, ins, p1, p2, Lc, data...]
    func apduMessage() -> Data {
        let lc = UInt8(data.count)
        return Data([cls, ins, p1, p2, lc] + data)
    }
}
