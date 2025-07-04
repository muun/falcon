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

    // If you change this constant, change it also in the push notification extension
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

    public var libwalletDataDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("libwallet", isDirectory: true)
    }

    public var libwalletSocketFile: URL {
#if targetEnvironment(simulator)
        // Here is something fun: OSX has a limit on the length of the path for a socket.
        // This limit is lower than the gigantic path to the .documentDirectory of the
        // simulator. So we have to use another path for the simulator.
        return URL(fileURLWithPath: "/tmp/wallet.sock")
#else
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("wallet.sock", isDirectory: false)
#endif
    }

    public static func getLocalhostByIp() -> String {
        return "localhost"
    }
}
