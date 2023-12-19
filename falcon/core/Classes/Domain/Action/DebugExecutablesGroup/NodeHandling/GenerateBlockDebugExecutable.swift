//
//  GenerateBlockDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import core

class GenerateBlockDebugExecutable: DebugExecutable {

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        TestLapp.generate(blocks: 1)
        completion()
    }

    func getTitleForCell() -> String {
        return "Generate block"
    }
}
