//
//  Environment.swift
//
//  Created by Juan Pablo Civile on 30/05/2019.
//

import Foundation

public enum Environment: String, RawRepresentable {
    case debug
    case regtest
    case dev
    case prod

    // If you change this constant, change it also in the core pod
    public static let current: Environment = .debug
}

extension Environment {

    public var buildType: String {
        switch self {
        case .debug:
            return "debug"
        case .regtest:
            return "regtest"
        case .dev:
            return "developmentDebug"
        case .prod:
            return "release"
        }
    }

    public var houstonURL: String {
        switch self {
        case .debug:
            return "http://\(Self.getLocalhostByIp()):8080"
        case .regtest:
            return "https://pub.reg.api.muun.wtf/houston"
        case .dev:
            return "https://dev.api.muun.wtf/houston"
        case .prod:
            return "https://pub.api.muun.io/houston"
        }
    }

    var muunWebURL: String {
        switch self {
        case .debug:
            return "http://\(Self.getLocalhostByIp()):3000"
        case .regtest:
            return "https://reg.muun.com"
        case .dev:
            return "https://dev.muun.com"
        case .prod:
            return "https://muun.com"
        }
    }

    var firebaseOptionsPath: String {
        let env = rawValue
        return Bundle.main.path(forResource: "GoogleService-Info-\(env)",
            ofType: "plist")!
    }

    public static func getLocalhostByIp() -> String {
            return "localhost"
    }
}
