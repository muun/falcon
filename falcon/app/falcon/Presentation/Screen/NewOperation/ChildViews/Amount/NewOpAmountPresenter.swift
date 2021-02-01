//
//  NewOpAmountPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 24/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

enum AmountState {
    case zero
    case valid
    case tooSmall
    case tooBig
}

protocol NewOpAmountPresenterDelegate: BasePresenterDelegate {
    func userDidChangeAmount(state: AmountState)
}

class NewOpAmountPresenter<Delegate: NewOpAmountPresenterDelegate>: BasePresenter<Delegate> {

    private let data: NewOperationStateLoaded
    private let totalBalance: Satoshis
    fileprivate var lastAmountEntered: MonetaryAmount?

    init(delegate: Delegate, state: NewOperationStateLoaded) {
        self.totalBalance = state.feeInfo.feeCalculator.totalBalance()
        self.data = state

        super.init(delegate: delegate)
    }

    func validityCheck(_ value: String, currency: String) {
        let amount = LocaleAmountFormatter.number(from: value, in: currency)
        let satoshiAmount = Satoshis.from(amount: amount.amount, at: rate(for: currency))

        if satoshiAmount == Satoshis(value: 0) {
            delegate.userDidChangeAmount(state: .zero)
            return
        }

        // This is weird, but the int64Value of a really big NSDecimalNumber returns a really low int
        // So we return amount too big when satoshi amount is a negative value
        // stackoverflow.com/questions/36322336/positive-nsdecimalnumber-returns-unexpected-64-bit-integer-values
        if satoshiAmount < Satoshis(value: 0) {
            delegate.userDidChangeAmount(state: .tooBig)
            return
        }

        if !data.type.allowsSpendingDust && satoshiAmount < Satoshis.dust {
            delegate.userDidChangeAmount(state: .tooSmall)
            return
        }

        let validAmount =
            amount.amount <= totalBalance(in: currency).amount
                || isSendingAllFundsManually(value: value, currency: currency)

        if !validAmount {
            delegate.userDidChangeAmount(state: .tooBig)
            return
        }

        delegate.userDidChangeAmount(state: .valid)
    }

    func getUserPrimaryCurrency() -> String {
        let window = data.feeInfo.exchangeRateWindow
        return data.user.primaryCurrencyWithValidExchangeRate(window: window)
    }

    func totalBalance(in currency: String) -> MonetaryAmount {
        return totalBalance.valuation(at: rate(for: currency), currency: currency)
    }

    func allFunds(in currency: String) -> BitcoinAmount {
        return BitcoinAmount(inSatoshis: totalBalance,
                             inInputCurrency: totalBalance(in: currency),
                             inPrimaryCurrency: totalBalance(in: getUserPrimaryCurrency()))
    }

    func amount(from value: String, in currency: String) -> BitcoinAmount {
        return BitcoinAmount.from(
            inputCurrency: LocaleAmountFormatter.number(from: value, in: currency),
            with: data.feeInfo.exchangeRateWindow,
            primaryCurrency: getUserPrimaryCurrency()
        )
    }

    private func rate(for currency: String) -> Decimal {
        do {
            return try data.feeInfo.exchangeRateWindow.rate(for: currency)
        } catch {
            Logger.fatal(error: error)
        }
    }

    func convert(value: String, in currency: String, to newCurrency: String) -> MonetaryAmount {

        var satoshis = Satoshis(value: 0)

        if let lastAmount = lastAmountEntered {
            satoshis = amount(
                from: LocaleAmountFormatter.string(from: lastAmount),
                in: lastAmount.currency
            ).inSatoshis
        } else {
            satoshis = amount(from: value, in: currency).inSatoshis
        }

        if isSendingAllFundsManually(value: value, currency: currency) {
            satoshis = totalBalance
        }

        return satoshis.valuation(at: rate(for: newCurrency), currency: newCurrency)
    }

    func isSendingAllFundsManually(value: String, currency: String) -> Bool {
        // This is to avoid bad roundings to stop users manually entering all their funds
        // I.E: User has 10000 Sats, conversion to usd is 10.009 USD, so muun displays max balance as 10.01 USD
        // Then without this code if the user enters 10.01 the conversion to sats will be more than 10000 sats, and
        // the flow will be interrupted.
        let totalBalanceAmountString = LocaleAmountFormatter.string(from: totalBalance(in: currency))
        return totalBalanceAmountString == value
    }

    func setLastAmountEntered(_ amount: MonetaryAmount?) {
        lastAmountEntered = amount
    }

}
