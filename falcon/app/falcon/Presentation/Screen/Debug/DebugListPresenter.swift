//
//  DebugListPresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 23/07/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import Foundation

protocol DebugListPresenter {
    func titleFor(cell: Int) -> String
    func numberOfRequests() -> Int
}
