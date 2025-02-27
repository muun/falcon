//
//  BaseDebugExecutables.swift
//  Muun
//
//  Created by Lucas Serruya on 23/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation

class BaseDebugExecutablesGroup: DebugExecutablesGroup {
    var category: String
    var executables: [DebugExecutable]

    init(category: String, executables: [DebugExecutable]) {
        self.category = category
        self.executables = executables
    }
}
