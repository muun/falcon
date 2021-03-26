//
//  Environment+Extension.swift
//  falcon
//
//  Created by Juan Pablo Civile on 31/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

extension Environment {
    var firebaseOptionsPath: String {
        return Bundle.main.path(forResource: "GoogleService-Info-\(rawValue)",
            ofType: "plist")!
    }

    public var txExplorer: String {
        switch self {
        case .dev:
            return "https://live.blockcypher.com/btc-testnet/tx/"
        case .debug, .regtest:
            return "http://totally-explorer/tx/"
        case .stg, .prod:
            return "https://mempool.space/tx/"
        }
    }

    public var addressExplorer: String {
        switch self {
        case .dev:
            return "https://live.blockcypher.com/btc-testnet/address/"
        case .debug, .regtest:
            return "http://totally-explorer/address/"
        case .stg, .prod:
            return "https://mempool.space/address/"
        }
    }

    public  var nodeExplorer: String {
        switch self {
        case .debug, .regtest:
            return "http://totally-1ml/node/"
        case .dev:
            return "https://1ml.com/testnet/node/"
        case .stg, .prod:
            return "https://1ml.com/node/"
        }
    }
}
