//
//  DropLastTxDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 17/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation

class DropLastTxDebugExecutable: DebugExecutable {
    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        TestLapp.dropLastTx()
        completion()
    }

    func getTitleForCell() -> String {
        return "Drop last tx"
    }
}
