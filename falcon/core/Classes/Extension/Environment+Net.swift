//
//  EnvironmetNet.swift
//  falcon
//
//  Created by Manu Herrera on 22/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Libwallet

extension Environment {
    public var network: LibwalletNetwork {
        switch self {
        case .debug, .regtest:
            return LibwalletRegtest()!
        case .dev:
            return LibwalletTestnet()!
        case .stg:
            return LibwalletMainnet()!
        case .prod:
            return LibwalletMainnet()!
        }
    }
}
