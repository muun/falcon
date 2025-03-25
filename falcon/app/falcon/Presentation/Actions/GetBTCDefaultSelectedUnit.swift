//
//  GetBTCDefaultSelectedUnit.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//



/// Gets default selected bitcoin unit using preferences.bool(forKey: .displayBTCasSAT)
class GetBTCDefaultSelectedUnit: Resolver {
    static func run() -> BitcoinCurrency {
        let preferences: Preferences = resolve()
        if preferences.bool(forKey: .displayBTCasSAT) {
            return BitcoinCurrency(unit: .SAT)
        }
        return BitcoinCurrency(unit: .BTC)
    }
}
