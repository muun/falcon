//
//  BitcoinUnitPickerPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 10/12/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

struct VisualCurrency: Currency {
    let code: String
    let symbol: String
    let name: String
    let flag: String?
}

protocol BitcoinUnitPickerPresenterDelegate: BasePresenterDelegate {}

class BitcoinUnitPickerPresenter<Delegate: BitcoinUnitPickerPresenterDelegate>: BasePresenter<Delegate> {

    private var currencies: [Currency] = []
    private var preferences: Preferences

    init(delegate: Delegate, preferences: Preferences) {
        self.preferences = preferences

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        currencies = [VisualCurrency(code: "BTC", symbol: "", name: "Bitcoin", flag: nil),
                      VisualCurrency(code: satSymbol, symbol: "", name: "Satoshi", flag: nil)]
    }

    func isSelected(_ currency: Currency) -> Bool {
        return currency.name == CurrencyHelper.bitcoinCurrency.name
    }

    func selectUnit(_ currency: Currency) {
        let isNewCurrencySats = currency.code == satSymbol
        preferences.set(value: isNewCurrencySats, forKey: .displayBTCasSAT)
    }

}

// TableView
extension BitcoinUnitPickerPresenter {

    func currency(forRowAt indexPath: IndexPath) -> Currency {
        return currencies[indexPath.row]
    }

}
