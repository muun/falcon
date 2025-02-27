//
//  CurrenciesForPickerRetrieverService.swift
//  Muun
//
//  Created by Lucas Serruya on 10/07/2022.
//  Copyright © 2022 muun. All rights reserved.
//


import Libwallet

protocol CurrenciesForPickerRetriever {
    func executeForMostUsed() -> [Currency]
    func executeForDisplayable() -> [Currency]
}

class InMemoryCurrenciesForPickerRetriever: CurrenciesForPickerRetriever {
    private let candidatesForMostUsedCurrency: [Currency]
    private let candidatesForAllCurrencies: [Currency]

    init(candidatesForMostUsedCurrency: [Currency], candidatesForAllCurrencies: [Currency]) {
        self.candidatesForMostUsedCurrency = candidatesForMostUsedCurrency
        self.candidatesForAllCurrencies = candidatesForAllCurrencies
    }

    func executeForMostUsed() -> [Currency] {
        var result: [Currency] = []
        for currency in candidatesForMostUsedCurrency {
            // Avoid duplicates
            if !result.contains(where: { $0 == currency }) {
                result.append(currency)
            }
        }

        return result.sorted(by: { $0.name < $1.name })
    }

    func executeForDisplayable() -> [Currency] {
        return candidatesForAllCurrencies
    }

    static func createForSettings(userSelector: UserSelector,
                                  exchangeRateWindow: NewopExchangeRateWindow) -> InMemoryCurrenciesForPickerRetriever {
        let userPrimaryCurrency = [getUserPrimaryCurrency(userSelector: userSelector,
                                                          exchangeRateWindow: exchangeRateWindow)]
        let candidates = CurrencyHelper.currencyList(currencyCodes: userPrimaryCurrency) + [
            CurrencyHelper.currencyForLocale(),
            CurrencyHelper.bitcoinCurrency,
            CurrencyHelper.dollarCurrency,
            CurrencyHelper.euroCurrency
        ]

        let currencesOnExchangeRateWindow = exchangeRateWindow.currencies()!.adapt()
        let candidatesForAllCurrencies = CurrencyHelper.currencyList(currencyCodes: currencesOnExchangeRateWindow)

        return InMemoryCurrenciesForPickerRetriever(candidatesForMostUsedCurrency: candidates,
                                             candidatesForAllCurrencies: candidatesForAllCurrencies)
    }

    static func createForContextualCurrencySelection(userSelector: UserSelector,
                                                     exchangeRateWindow: NewopExchangeRateWindow) -> InMemoryCurrenciesForPickerRetriever {
        let userPrimaryCurrency = [getUserPrimaryCurrency(userSelector: userSelector,
                                                          exchangeRateWindow: exchangeRateWindow)]
        let primaryCurrency = CurrencyHelper.currencyList(currencyCodes: userPrimaryCurrency).first
        var candidates = [
            CurrencyHelper.currencyForLocale(),
            BitcoinCurrency(unit: .BTC),
            BitcoinCurrency(unit: .SAT),
            CurrencyHelper.dollarCurrency,
            CurrencyHelper.euroCurrency
        ]

        if let primaryCurrency = primaryCurrency, !(primaryCurrency is BitcoinCurrency) {
            candidates += [primaryCurrency]
        }

        let currenciesOnExchangeRateWindow = exchangeRateWindow.currencies()!.adapt()
        let candidatesForAllCurrencies = CurrencyHelper.currencyList(currencyCodes: currenciesOnExchangeRateWindow)

        return InMemoryCurrenciesForPickerRetriever(candidatesForMostUsedCurrency: candidates,
                                             candidatesForAllCurrencies: candidatesForAllCurrencies)
    }

    private static func getUserPrimaryCurrency(userSelector: UserSelector,
                                               exchangeRateWindow: NewopExchangeRateWindow) -> String {
        let user: User
        do {
            user = try userSelector.get().toBlocking().single()
        } catch {
            Logger.fatal(error: error)
        }

        return user.primaryCurrencyWithValidExchangeRate(window: exchangeRateWindow)
    }
}
