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

    private let exchangeRateWindow: NewopExchangeRateWindow
    private var currencies: [Currency] = []
    private var mostUsedCurrencies: [Currency] = []
    private var displayableCurrencies: [Currency] = []
    private var userSelector: UserSelector
    private let exchangeRateWindowRepository: ExchangeRateWindowRepository

    init(delegate: Delegate, state: NewopExchangeRateWindow, userSelector: UserSelector, exchangeRateWindowRepository: ExchangeRateWindowRepository) {
        self.exchangeRateWindow = state
        self.userSelector = userSelector
        self.exchangeRateWindowRepository = exchangeRateWindowRepository

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        currencies = CurrencyHelper.currencyList(currencyCodes: exchangeRateWindow.currencies()!.adapt())
        displayableCurrencies = currencies
        mostUsedCurrencies = buildMostUsedCurrencies()

    }

    func buildMostUsedCurrencies() -> [Currency] {

        let user: User
        do {
            user = try userSelector.get().toBlocking().single()
        } catch {
            Logger.fatal(error: error)
        }

        let userPrimaryCurrency = user.primaryCurrencyWithValidExchangeRate(window: exchangeRateWindow)

        let candidates = CurrencyHelper.currencyList(currencyCodes: [userPrimaryCurrency]) + [
            CurrencyHelper.currencyForLocale(),
            CurrencyHelper.bitcoinCurrency,
            CurrencyHelper.dollarCurrency,
            CurrencyHelper.euroCurrency
        ]

        var result: [Currency] = []
        for currency in candidates {
            // Avoid duplicates
            if !result.contains(where: { $0.code == currency.code }) {
                result.append(currency)
            }
        }

        return result.sorted(by: { $0.name < $1.name })
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
