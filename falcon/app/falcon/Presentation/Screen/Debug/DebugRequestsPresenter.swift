//
//  DebugRequestsPresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 21/09/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import core

protocol DebugRequestsPresenterDelegate: BasePresenterDelegate,
                                         MUViewController {
}

class DebugRequestsPresenter<Delegate: DebugRequestsPresenterDelegate>: BasePresenter<Delegate>,
                                                                            DebugListPresenter {

    private let debugRequests: [DebugRequest]

    init(delegate: Delegate,
         debugRequestsRepository: DebugRequestsRepository) {
        debugRequests = debugRequestsRepository.getAll()

        super.init(delegate: delegate)
    }

    func titleFor(cell: Int) -> String {
        let path = debugRequests[cell].url.contains("houston") ? "houston" : "8080"

        return debugRequests[cell].url.components(separatedBy: path)[1]
    }

    func numberOfRequests() -> Int {
        return debugRequests.count
    }

    func getRequestFor(cell: Int) -> DebugRequest {
        return debugRequests[cell]
    }
}
