//
//  TestUtils.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 30/09/2020.
//

import Foundation

public func runWhenTesting(_ f: @autoclosure () -> ()) {
    #if DEBUG
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
        f()
    }
    #endif
}

public func runWhenNotTesting(_ f: @autoclosure () -> ()) {
    #if DEBUG
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
        return
    }
    #endif

    f()
}
