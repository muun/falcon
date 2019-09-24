//
//  MuunError.swift
//  falcon
//
//  Created by Juan Pablo Civile on 22/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct MuunError: Error {

    let stackSymbols: [String]
    public let kind: Error

    public init(_ kind: Error, filename: StaticString = #file, line: UInt = #line, funcName: StaticString = #function) {
        self.kind = kind
        let callsite = "[\(MuunError.sourceFileName(filePath: filename))]:\(line) \(funcName)"
        self.stackSymbols = [callsite] + Thread.callStackSymbols
    }

    static func sourceFileName(filePath: StaticString) -> String {

        let string = filePath.description
        let components = string.components(separatedBy: "/")
        guard let start = components.lastIndex(of: "falcon") else {
            return string
        }

        return components.suffix(from: start.advanced(by: 1)).joined(separator: "/")
    }

    public var kindDescription: String {
        return kind.localizedDescription
    }
}
