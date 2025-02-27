//
//  NSErrorHelper.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

// TODO: copy this to NotificationService
public struct LibwalletError: Error {
    enum ErrorKind {
        case network
        case invalidUri
        case unknown
    }

    let kind: ErrorKind
    let description: String

    var localizedDescription: String {
        return description
    }

    public static func from(_ err: Error) -> LibwalletError {
        let code = LibwalletErrorCode(err)
        var description = err.localizedDescription

        let kind: ErrorKind
        switch code {
        case LibwalletErrNetwork:
            kind = .network
        case LibwalletErrInvalidURI:
            kind = .invalidUri
        case LibwalletErrUnknown:
            kind = .unknown
        default:
            kind = .unknown
            description += " (code \(code))"
        }

        return LibwalletError(kind: kind, description: description)
    }
}

public func doWithError<T>(_ f: (NSErrorPointer) throws -> T?) throws -> T {
    var err: NSError?
    let result = try f(&err)
    if let err = err {
        throw MuunError(LibwalletError.from(err))
    }

    if let result = result {
        return result
    } else {
        throw MuunError(DoWithErrors.nilResult)
    }
}

enum DoWithErrors: Error {
    case nilResult
}
