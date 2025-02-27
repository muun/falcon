//
//  ExpectationUtils.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest

@testable import Muun

func AssertThrowsError<T, E>(_ expression: @autoclosure () throws -> T,
                             _ type: E.Type = E.self,
                             file: StaticString = #file,
                             line: UInt = #line,
                             _ validator: (E) -> Bool = { _ in true }) where E: Error {

    do {
        _ = try expression()

        XCTFail("expression did not throw", file: file, line: line)
    } catch {

        let errorToCheck: Error
        if let muunError = error as? MuunError {
            errorToCheck = muunError.kind
        } else {
            errorToCheck = error
        }

        guard let err = errorToCheck as? E else {
            XCTFail("Error is not of type \(type): \(errorToCheck)", file: file, line: line)
            return
        }

        XCTAssert(validator(err), "expected error to match validator: \(err)", file: file, line: line)

    }
}
