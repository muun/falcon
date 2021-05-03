//
//  ReceiveAmountInputPresenter.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import core

protocol ReceiveAmountInputPresenterDelegate: BasePresenterDelegate {

}

class ReceiveAmountInputPresenter<Delegate: ReceiveAmountInputPresenterDelegate>: BasePresenter<Delegate> {

    private let userRepository: UserRepository
    private let exchangeRateRepository: ExchangeRateWindowRepository
    private let sessionActions: SessionActions

    init(delegate: Delegate,
         userRepository: UserRepository,
         exchangeRateRepository: ExchangeRateWindowRepository,
         sessionActions: SessionActions) {

        self.userRepository = userRepository
        self.exchangeRateRepository = exchangeRateRepository
        self.sessionActions = sessionActions
        super.init(delegate: delegate)
    }

    func getExchangeRateWindow() -> ExchangeRateWindow {
        return exchangeRateRepository.getExchangeRateWindow()! // TODO: review
    }

    func getUserPrimaryCurrency() -> String {
        return sessionActions.getPrimaryCurrency()
    }

    func amount(from value: String, in currency: String) -> BitcoinAmount {
        return BitcoinAmount.from(
            inputCurrency: LocaleAmountFormatter.number(from: value, in: currency),
            with: getExchangeRateWindow(),
            primaryCurrency: getUserPrimaryCurrency()
        )
    }

    func convert(value: String, in currency: String, to newCurrency: String) -> MonetaryAmount {

        let satoshis = amount(from: value, in: currency).inSatoshis

        return satoshis.valuation(at: rate(for: newCurrency), currency: newCurrency)
    }

    private func rate(for currency: String) -> Decimal {
        do {
            let window = getExchangeRateWindow()
            return try window.rate(for: currency)
        } catch {
            Logger.fatal(error: error)
        }
    }

    func validityCheck(amount value: String,
                       currency: String,
                       for receiveType: ReceiveType) -> AmountInputView.State {

        let amount = LocaleAmountFormatter.number(from: value, in: currency)

        let satoshiAmount: Satoshis
        do {
            satoshiAmount = try Satoshis.bounded(amount: amount.amount, at: rate(for: currency))
        } catch {
            return .tooBig
        }

        if satoshiAmount == Satoshis(value: 0) {
            if amount.amount > 0 {
                return .tooSmall
            }
            return .zero
        }

        if receiveType == .onChain && satoshiAmount < Satoshis.dust {
            return .tooSmall
        }

        return .valid
    }

    func getSecondaryAmount(amount: String, currency: String) -> MonetaryAmount? {
        if currency == "BTC" {
            let primaryCurrency = getUserPrimaryCurrency()
            if primaryCurrency != "BTC" {
                return convert(value: amount, in: currency, to: primaryCurrency)
            }
            return nil
        }
        return convert(value: amount, in: currency, to: "BTC")
    }

}
