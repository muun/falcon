//
//  DebugAnalyticsPresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 23/07/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import core

protocol DebugAnalyticsPresenterDelegate: BasePresenterDelegate,
                                         MUViewController {
}

class DebugAnalyticsPresenter<Delegate: DebugAnalyticsPresenterDelegate>: BasePresenter<Delegate>,
                                                                          DebugListPresenter {

    private let analyticsEvents: [DebugAnalyticsEvent]

    init(delegate: Delegate,
         debugRequestsRepository: DebugAnalyticsRepository) {
        analyticsEvents = debugRequestsRepository.getAll()

        super.init(delegate: delegate)
    }

    func titleFor(cell: Int) -> String {
        return analyticsEvents[cell].event + "\n"
        + (paramsToString(dictionary: analyticsEvents[cell].params) ?? "")
    }

    private func paramsToString<T>(dictionary: [T: Any]?) -> String? {
        guard let dictionary = dictionary else {
            return nil
        }

        var formattedHeaders = ""

        dictionary.forEach {
            formattedHeaders += "[\($0.key): \($0.value)]\n"
        }

        return formattedHeaders
    }

    func numberOfRequests() -> Int {
        return analyticsEvents.count
    }
}
