//
//  AsciiSanitizer.swift
//  falcon
//
//  Created by FMucci on 09/04/2025.
//  Copyright © 2025 muun. All rights reserved.
//

struct AsciiUtils {
    func toSafeAscii(_ value: String) -> String {
        var result = ""
        for utf16Unit in value.utf16 {
            if utf16Unit < 128 {
                result.append(Character(UnicodeScalar(utf16Unit)!))
            } else {
                result += String(format: "\\u%04X", utf16Unit) // <- Mayúscula
            }
        }
        return result
    }
}
