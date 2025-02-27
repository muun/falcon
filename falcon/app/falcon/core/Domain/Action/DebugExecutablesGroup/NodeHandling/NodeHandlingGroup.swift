//
//  NodeHandlingGroup.swift
//  Muun
//
//  Created by Lucas Serruya on 23/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

class NodeHandlingGroup: BaseDebugExecutablesGroup {
    init() {
        super.init(category: "Node handling",
                   executables: [GenerateBlockDebugExecutable(),
                                 DropLastTxDebugExecutable(),
                                 DropTxByIdDebugExecutable(),
                                 UndropTxByIdDebugExecutable()])
    }
}
