//
//  DebugAnalyticsEventsRepository.swift
//
//  Created by Lucas Serruya on 23/07/2024.
//

import Foundation

// This repository store request ON DEBUG only
public class DebugAnalyticsRepository {
    var storedEvents = [DebugAnalyticsEvent]()

    public func save(event: String,
                     params: [String: Any]) {
        #if DEBUG
        let debugRequest = DebugAnalyticsEvent(event: event, params: params)
        storedEvents.append(debugRequest)
        #endif
    }

    public func getAll() -> [DebugAnalyticsEvent] {
        #if DEBUG
        storedEvents
        #else
        return []
        #endif
    }
}

public struct DebugAnalyticsEvent {
    public let event: String
    public let params: [String: Any]
}
