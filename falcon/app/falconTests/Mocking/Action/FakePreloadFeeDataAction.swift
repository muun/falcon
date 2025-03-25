//
//  FakePreloadFeeDataAction.swift
//  falconTests
//
//  Created by Daniel Mankowski on 04/11/2024.
//  Copyright © 2024 muun. All rights reserved.
//

@testable import Muun
import XCTest

final class FakePreloadFeeDataAction: PreloadFeeDataAction {

    var forceRunExpectation: XCTestExpectation?
    var forceRunCalledCount: Int = 0
    override func forceRun(refreshPolicy: FeeBumpRefreshPolicy) {
        forceRunCalledCount += 1
        forceRunExpectation?.fulfill()
    }

    var runCalledCount: Int = 0
    public override func run() {
        runCalledCount += 1
    }
}
