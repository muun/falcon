//
//  GetCurrencyForCode.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation

/// Gets currency for a given code. In case code is BTC, bitcoin unit is choosen from GetBTCDefaultSelectedUnit
class GetCurrencyForCode {
    /// Execute action. If code is BTC the returned unit will be user defaults unit.
    /// > Warning: If code is not found this function calls FATAL ERROR
    func runAssumingCrashPosibility(code: String) -> Currency {
        if code == "BTC" {
            return GetBTCDefaultSelectedUnit.run()
        }
        guard let currency = CurrencyHelper.allCurrencies[code] else {
            fatalError("currency not found \(code)")
        }

        return currency
    }

    /// > Warning: This method will use Bitcoin Unit from userDefaults.
    func runDefaultingFiat(code: String) -> Currency {
        if code == "BTC" {
            return GetBTCDefaultSelectedUnit.run()
        }

        guard let currency = CurrencyHelper.allCurrencies[code] else {
            return FiatCurrency(code: code, symbol: "", name: "", flag: nil)
        }

        return currency
    }
}
