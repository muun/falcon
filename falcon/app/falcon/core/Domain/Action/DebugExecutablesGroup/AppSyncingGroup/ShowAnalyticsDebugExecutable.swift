//
//  ShowAnalyticsDebugExecutable.swift
//
//  Created by Lucas Serruya on 23/07/2024.
//

import Foundation
import Foundation

import RxSwift

class ShowAnalyticsDebugExecutable: DebugExecutable {
    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        context.showAnalytics()
        completion()
    }

    func getTitleForCell() -> String {
        return "Show Analytics Events"
    }
}
