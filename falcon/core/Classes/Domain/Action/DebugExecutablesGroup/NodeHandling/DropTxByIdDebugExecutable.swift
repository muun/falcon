//
//  DropTxByIdDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 17/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation

class DropTxByIdDebugExecutable: DebugExecutable {
    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        context.askUserForText(message: "Insert tx id") { txId in
            TestLapp.dropTx(id: txId)
            completion()
        }
    }

    func getTitleForCell() -> String {
        return "Drop tx by id"
    }
}
