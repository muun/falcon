//
//  FakePinURLService.swift
//  falconTests
//
//  Created by Lucas Serruya on 30/10/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import RxSwift
@testable import core

class FakePingURLService: PingURLService {
    var pingExpected = true
    var runCalledCount = 0

    override func run(url: String) -> Single<Bool> {
        runCalledCount += 1
        return Single.create { completion in
            completion(.success(self.pingExpected))

            return Disposables.create()
        }
    }
}
