//
//  NSErrorHelper.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public func doWithError<T>(_ f: (NSErrorPointer) throws -> T?) throws -> T {
    var err: NSError?
    let result = try f(&err)
    if let err = err {
        throw MuunError(err)
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
