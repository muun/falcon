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

protocol NewOpAmountPresenterDelegate: BasePresenterDelegate {}

class NewOpAmountPresenter<Delegate: NewOpAmountPresenterDelegate>: BasePresenter<Delegate> {

    private let sessionActions: SessionActions

    var data: NewOperationStateLoaded

    init(delegate: Delegate, state: NewOperationStateLoaded, sessionActions: SessionActions) {
        self.data = state
        self.sessionActions = sessionActions

        super.init(delegate: delegate)
    }

    // TODO: Tech debt. This is dangerous domain logic and must be thoroughly tested
    func validityCheck(_ value: String, currency: Currency) -> AmountInputView.State {
        precondition(currency.code == data.totalBalance.inInputCurrency.currency)

        let amount = currency.formattedNumber(from: value)
        let satoshiAmount = Satoshis.from(amount: amount.amount, at: rate(for: currency.code))

        if satoshiAmount == Satoshis(value: 0) {
            return .zero
        }

        // This is weird, but the int64Value of a really big NSDecimalNumber returns a really low int
        // So we return amount too big when satoshi amount is a negative value
        // stackoverflow.com/questions/36322336/positive-nsdecimalnumber-returns-unexpected-64-bit-integer-values
        if satoshiAmount < Satoshis(value: 0) {
            return .tooBig
        }

        if !data.type.allowsSpendingDust && satoshiAmount < Satoshis.dust {
            return .tooSmall
        }

        let validAmount =
        amount.amount <= totalBalance(in: currency.code).amount
        || isSendingAllFundsManually(value: value, currency: currency)

        if !validAmount {
            return .tooBig
        }

        return .valid
    }

    func getUserPrimaryCurrency() -> String {
        return data.primaryCurrency
    }

    func totalBalance(in currency: String) -> MonetaryAmount {
        return data.totalBalance.inSatoshis.valuation(at: rate(for: currency), currency: currency)
    }

    func allFunds(in currency: String) -> BitcoinAmount {
        return BitcoinAmount(
            inSatoshis: data.totalBalance.inSatoshis,
            inInputCurrency: totalBalance(in: currency),
            inPrimaryCurrency: totalBalance(in: data.primaryCurrency)
        )
    }

    func amount(from value: String, in currency: Currency) -> BitcoinAmount {
        return BitcoinAmount.from(inputCurrency: currency.formattedNumber(from: value),
                                  rate: data.rate,
                                  primaryCurrency: data.primaryCurrency)
    }

    private func rate(for currency: String) -> Decimal {
        return data.rate(for: currency)
    }

    func convert(value: String, in currency: Currency, to newCurrency: Currency) -> MonetaryAmount {

        var satoshis = amount(from: value, in: currency).inSatoshis

        if isSendingAllFundsManually(value: value, currency: currency) {
            satoshis = data.totalBalance.inSatoshis
        }

        return satoshis.valuation(at: rate(for: newCurrency.code), currency: newCurrency.code)
    }

    func isSendingAllFundsManually(value: String, currency: Currency) -> Bool {
        // This is to avoid bad roundings to stop users manually entering all their funds
        // I.E: User has 10000 Sats, conversion to usd is 10.009 USD, so muun displays max balance as 10.01 USD
        // Then without this code if the user enters 10.01 the conversion to sats will be more than 10000 sats, and
        // the flow will be interrupted.
        let totalBalanceAmountString = currency.toAmountWithoutCode(amount: totalBalance(in: currency.code).amount,
                                                                btcCurrencyFormat: .long)
        return totalBalanceAmountString == value
    }

}
