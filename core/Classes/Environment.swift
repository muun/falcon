//
//  Environment.swift
//  core
//
//  Created by Juan Pablo Civile on 30/05/2019.
//

import Foundation

public enum Environment: String, RawRepresentable {
    case debug
    case dev
    case stg
    case prod

    // If you change this constant, change it also in the push notification extension
    public static let current: Environment = .debug
}

extension Environment {

    public var buildType: String {
        switch self {
        case .debug:
            return "debug"
        case .dev:
            return "developmentDebug"
        case .stg:
            return "staging"
        case .prod:
            return "release"
        }
    }

    public var houstonURL: String {
        switch self {
        case .debug:
            return "http://localhost:8080"
        case .dev:
            return "https://dev.api.muun.wtf/houston"
        case .stg:
            return "https://stg.api.muun.wtf/houston"
        case .prod:
            return "https://pub.api.muun.io/houston"
        }
    }

    var muunWebURL: String {
        switch self {
        case .debug:
            return "http://localhost:3000"
        case .dev:
            return "https://dev.muun.com"
        case .stg:
            return "https://stg.muun.com"
        case .prod:
            return "https://muun.com"
        }
    }
}
