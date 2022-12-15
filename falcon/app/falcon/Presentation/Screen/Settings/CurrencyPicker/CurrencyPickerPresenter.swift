//
//  CurrencyPickerPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 21/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import Libwallet
import core

protocol CurrencyPickerPresenterDelegate: BasePresenterDelegate {
    func gotCurrencyList()
}

class CurrencyPickerPresenter<Delegate: CurrencyPickerPresenterDelegate>: BasePresenter<Delegate> {

    private let currenciesRepostory: CurrenciesForPickerRetrieverService
    private var currencies: [Currency] = []
    private var mostUsedCurrencies: [Currency] = []
    private var displayableCurrencies: [Currency] = []
    private var userSelector: UserSelector

    init(delegate: Delegate,
         state: CurrenciesForPickerRetrieverService,
         userSelector: UserSelector) {
        self.currenciesRepostory = state
        self.userSelector = userSelector

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        currencies = currenciesRepostory.executeForDisplayable()
        displayableCurrencies = currencies
        mostUsedCurrencies = currenciesRepostory.executeForMostUsed()
    }

    func filter(_ text: String) {
        if text != "" {
            displayableCurrencies = currencies.filter({
                $0.name.uppercased().contains(text.uppercased())
                    || $0.code.uppercased().contains(text.uppercased())
            })
        } else {
            displayableCurrencies = currencies
        }
    }

}

// TableView
extension CurrencyPickerPresenter {

    func currenciesCount(forSection section: Int) -> Int {
        let currencyCount = (section == 0)
            ? mostUsedCurrencies.count
            : displayableCurrencies.count

        return currencyCount
    }

    func currency(forRowAt indexPath: IndexPath) -> Currency {
        let currency = (indexPath.section == 0)
            ? mostUsedCurrencies[indexPath.row]
            : displayableCurrencies[indexPath.row]

        return currency
    }

}
