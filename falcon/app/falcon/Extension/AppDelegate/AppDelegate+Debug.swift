//
//  AppDelegate+Debug.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit

extension AppDelegate {
    func setupDebugModeIfNeeded() {
        #if !DEBUG
        return
        #endif

        debugModeDisplayer = DebugModeDisplayer()
        debugModeDisplayer?.startDebugDisplayerIfDebugBuild()
    }
}
