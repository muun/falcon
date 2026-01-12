//
//  FakeFeeBumpFunctionsProvider.swift
//  falconTests
//
//  Created by Daniel Mankowski on 25/10/2024.
//  Copyright © 2024 muun. All rights reserved.
//

@testable import Muun

final class FakeFeeBumpFunctionsProvider: FeeBumpFunctionsProvider {

    var persistFeeBumpFunctionsCalledCount = 0
    func persistFeeBumpFunctions(feeBumpFunctions: FeeBumpFunctions, refreshPolicy: FeeBumpRefreshPolicy) {
        persistFeeBumpFunctionsCalledCount += 1
    }

    var areFeeBumpFunctionsInvalidatedResult: Bool = true
    var areFeeBumpFunctionsInvalidatedCalledCount = 0
    func areFeeBumpFunctionsInvalidated() -> Bool {
        areFeeBumpFunctionsInvalidatedCalledCount += 1
        return areFeeBumpFunctionsInvalidatedResult
    }
}
