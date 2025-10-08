//
//  DebugExecutablesGroup.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation

public protocol DebugExecutablesGroup {
    var category: String { get set }
    var executables: [DebugExecutable] { get set }
}

public protocol DebugExecutable {
    func getTitleForCell() -> String
    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void)
}

public protocol DebugMenuExecutableContext {
    func askUserForText(message: String, completion: @escaping (String) -> Void)
    func showAlert(title: String?, message: String?)
    func showRequests()
    func showAnalytics()
}
