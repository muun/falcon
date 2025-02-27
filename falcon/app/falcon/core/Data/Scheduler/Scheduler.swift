//
//  Scheduler.swift
//  falcon
//
//  Created by Manu Herrera on 17/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift

public enum Scheduler {

    public static let backgroundScheduler: SchedulerType = {
        #if DEBUG
        // Use the main thread for background when in tests to reduce tests flakyness
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return foregroundScheduler
        }
        #endif

        return ConcurrentDispatchQueueScheduler(qos: .background)
    }()

    public static let foregroundScheduler = ConcurrentMainScheduler.instance

    public static let userInitiatedScheduler = ConcurrentDispatchQueueScheduler(
        queue: DispatchQueue.global(qos: .userInitiated)
    )
}
