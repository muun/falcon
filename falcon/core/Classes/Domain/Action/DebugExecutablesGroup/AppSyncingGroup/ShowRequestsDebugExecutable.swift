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

class ShowRequestsDebugExecutable: DebugExecutable {
    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        context.showRequests()
        completion()
    }

    func getTitleForCell() -> String {
        return "Show requests history"
    }
}
