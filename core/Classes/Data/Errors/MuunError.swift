//
//  MuunError.swift
//  falcon
//
//  Created by Juan Pablo Civile on 22/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct MuunError: Error, LocalizedError {

    let stacktrace: [NSNumber]
    let callsite: String
    let shortCallsite: String
    public let kind: Error

    public init(_ kind: Error, filename: StaticString = #file, line: UInt = #line, funcName: StaticString = #function) {
        self.kind = kind
        self.callsite = "[\(MuunError.sourcePath(filePath: filename))]:\(line) \(funcName)"
        self.shortCallsite = "\(MuunError.sourceFileName(filePath: filename)) \(funcName)"
        self.stacktrace = Thread.callStackReturnAddresses
    }

    static func sourcePath(filePath: StaticString) -> String {

        let string = filePath.description
        let components = string.components(separatedBy: "/")
        guard let start = components.lastIndex(of: "falcon") else {
            return string
        }

        return components.suffix(from: start.advanced(by: 1)).joined(separator: "/")
    }

    static func sourceFileName(filePath: StaticString) -> String {

        let string = filePath.description
        let components = string.components(separatedBy: "/")
        return components.last ?? "<unknown>"
    }

    public var errorDescription: String? {
        return "\(callsite): \(kind)"
    }

    public var shortDescription: String {
        return "\(shortCallsite): \(kind)"
    }
}
