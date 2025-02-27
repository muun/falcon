//
//  ReceiveAmountInputPresenter.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation

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

    func amountWithCurrency(from value: String, in currency: Currency) -> BitcoinAmountWithSelectedCurrency {
        let bitcoinAmount = BitcoinAmount.from(inputCurrency: currency.formattedNumber(from: value),
                                               with: getExchangeRateWindow(),
                                               primaryCurrency: getUserPrimaryCurrency())
        return BitcoinAmountWithSelectedCurrency(bitcoinAmount: bitcoinAmount,
                                                 selectedCurrency: currency)
    }

    func convert(value: String, in currency: Currency, to newCurrency: Currency) -> MonetaryAmount {
        let satoshis = amountWithCurrency(from: value, in: currency).bitcoinAmount.inSatoshis

        return satoshis.valuation(at: rate(for: newCurrency.code), currency: newCurrency.code)
    }

    private func rate(for currency: String) -> Decimal {
        do {
            let window = getExchangeRateWindow()
            return try window.rate(for: currency)
        } catch {
            Logger.fatal(error: error)
        }
    }
    // TODO: Tech debt. This is dangerous domain logic and must be thoroughly tested
    func validityCheck(amount value: String,
                       currency: Currency,
                       for receiveType: ReceiveType) -> AmountInputView.State {

        let amount = currency.formattedNumber(from: value)

        let satoshiAmount: Satoshis
        do {
            satoshiAmount = try Satoshis.bounded(amount: amount.amount, at: rate(for: currency.code))
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

    func getSecondaryAmount(amount: String, currency: Currency) -> MonetaryAmountWithCompleteDataOfCurrency? {
        if currency.code == "BTC" {
            let primaryCurrency = getUserPrimaryCurrency()
            if primaryCurrency != "BTC" {
                let completedCurrency = GetCurrencyForCode().runAssumingCrashPosibility(code: primaryCurrency)
                let convertedMonetaryAmount = convert(value: amount, in: currency, to: completedCurrency)
                return MonetaryAmountWithCompleteDataOfCurrency(monetaryAmount: convertedMonetaryAmount,
                                                                currency: completedCurrency)
            }
            return nil
        }

        // if currency code is not BTC then it is converting to BTC.
        let currentCurrency = GetBTCDefaultSelectedUnit.run()
        let convertedAmount = convert(value: amount, in: currency, to: currentCurrency)

        return MonetaryAmountWithCompleteDataOfCurrency(monetaryAmount: convertedAmount,
                                                        currency: currentCurrency)
    }

}
