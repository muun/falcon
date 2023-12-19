//
//  SyncRealtimeDataDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation

import core
import RxSwift

class SyncRealtimeDataDebugExecutable: DebugExecutable {
    private let realTimeDataAction: RealTimeDataAction

    init(realTimeDataAction: RealTimeDataAction) {
        self.realTimeDataAction = realTimeDataAction
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        realTimeDataAction.run(forceUpdate: true)
        completion()
    }

    func getTitleForCell() -> String {
        return "Sync real time data"
    }
}
