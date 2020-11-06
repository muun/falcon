//
//  ErrorExtensionTests.swift
//  core.root-all-notifications-Unit-Tests
//
//  Created by Juan Pablo Civile on 14/10/2020.
//

import Foundation
import XCTest
@testable import core

class ErrorExtensionTests: XCTestCase {

    func testIsKindOf() {
        XCTAssertTrue(developerError(code: 5003).isKindOf(ExactDeveloperError.emailNotRegistered))
        XCTAssertFalse(developerError(code: 5003).isKindOf(ExactDeveloperError.defaultError))

        XCTAssertFalse(MuunError(Errors.test).isKindOf(ExactDeveloperError.emailNotRegistered))
    }

    private func developerError(code: Int) -> Error {
        return MuunError(ServiceError.customError(DeveloperError(
            developerMessage: nil,
            errorCode: code,
            message: "error",
            requestId: 0,
            status: 0
        )))
    }

    func testContains() {
        XCTAssertTrue(MuunError(Errors.test).contains(Errors.test))
        XCTAssertTrue(Errors.test.contains(Errors.test))

        XCTAssertFalse(MuunError(Errors.test).contains(Errors.other))
        XCTAssertFalse(Errors.test.contains(Errors.other))

        XCTAssertFalse(MuunError(Errors.test).contains(OtherErrors.error))
        XCTAssertFalse(Errors.test.contains(OtherErrors.error))
    }

    enum Errors: String, RawRepresentable, Error {
        case test
        case other
    }

    enum OtherErrors: Error {
        case error
    }

}
