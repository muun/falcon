//
//  BitcoinAmountWithSelectedCurrency.swift
//  Muun
//
//  Created by Lucas Serruya on 08/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import core

/// Struct to hold BitcoinAmount and the selectedCurrency on current flow.
/// This struct is necessary because there is no way looking at Currencyhelper to be sure what bitcoin unit was
/// selected by an user in case the user selects a specific bitcoin unit for a given flow.
/// Looking at bitcoinAmount.inInputCurrency you can only figure out if currency is bitcoin not specific bitcoin unit
struct BitcoinAmountWithSelectedCurrency: Equatable {
    var bitcoinAmount: BitcoinAmount
    var selectedCurrency: Currency

    static func == (lhs: BitcoinAmountWithSelectedCurrency, rhs: BitcoinAmountWithSelectedCurrency) -> Bool {
        lhs.bitcoinAmount == rhs.bitcoinAmount && lhs.selectedCurrency.displayCode == rhs.selectedCurrency.displayCode
    }
}
