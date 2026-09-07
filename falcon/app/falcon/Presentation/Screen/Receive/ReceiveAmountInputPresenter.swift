//
//  ReceiveAmountInputPresenter.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import Libwallet

protocol ReceiveAmountInputPresenterDelegate: BasePresenterDelegate {

}

class ReceiveAmountInputPresenter<Delegate: ReceiveAmountInputPresenterDelegate>: BasePresenter<
    Delegate
> {

    private let userRepository: UserRepository
    private let exchangeRateRepository: ExchangeRateWindowRepository
    private let sessionActions: SessionActions

    init(
        delegate: Delegate,
        userRepository: UserRepository,
        exchangeRateRepository: ExchangeRateWindowRepository,
        sessionActions: SessionActions
    ) {

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

    func amountWithCurrency(
        from value: String,
        in currency: Currency
    ) -> BitcoinAmountWithSelectedCurrency {
        let bitcoinAmount = BitcoinAmount.from(
            inputCurrency: currency.formattedNumber(from: value),
            with: getExchangeRateWindow(),
            primaryCurrency: getUserPrimaryCurrency()
        )
        return BitcoinAmountWithSelectedCurrency(
            bitcoinAmount: bitcoinAmount,
            selectedCurrency: currency
        )
    }

    func convert(value: String, in currency: Currency, to newCurrency: Currency) -> MonetaryAmount {
        let satoshis = amountWithCurrency(from: value, in: currency).bitcoinAmount.inSatoshis

        return satoshis.valuation(at: rate(for: newCurrency.code), currency: newCurrency.code)
    }

    private func rate(for currency: String) -> Decimal {
        // An unusable or missing rate degrades to 0 (yielding a 0 amount) instead of crashing.
        return getExchangeRateWindow().displayRate(for: currency) ?? 0
    }
    // TODO: Tech debt. This is dangerous domain logic and must be thoroughly tested
    func validityCheck(
        amount value: String,
        currency: Currency,
        for receiveType: ReceiveType
    ) -> AmountInputView.State {

        let amount = currency.formattedNumber(from: value)

        let satoshiAmount: Satoshis
        do {
            satoshiAmount = try Satoshis.bounded(
                amount: amount.amount,
                at: rate(for: currency.code)
            )
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

    func getSecondaryAmount(
        amount: String,
        currency: Currency
    ) -> MonetaryAmountWithCompleteDataOfCurrency? {
        if currency.code == "BTC" {
            let primaryCurrency = getUserPrimaryCurrency()
            if primaryCurrency != "BTC" {
                // Hide the secondary line when the primary currency has no usable rate, instead of
                // showing a misleading "0.00 <primary>".
                guard getExchangeRateWindow().displayRate(for: primaryCurrency) != nil else {
                    return nil
                }
                let completedCurrency = GetCurrencyForCode()
                    .runAssumingCrashPosibility(code: primaryCurrency)
                let convertedMonetaryAmount = convert(
                    value: amount,
                    in: currency,
                    to: completedCurrency
                )
                return MonetaryAmountWithCompleteDataOfCurrency(
                    monetaryAmount: convertedMonetaryAmount,
                    currency: completedCurrency
                )
            }
            return nil
        }

        // if currency code is not BTC then it is converting to BTC.
        let currentCurrency = GetBTCDefaultSelectedUnit.run()
        let convertedAmount = convert(value: amount, in: currency, to: currentCurrency)

        return MonetaryAmountWithCompleteDataOfCurrency(
            monetaryAmount: convertedAmount,
            currency: currentCurrency
        )
    }

}

enum ReceiveInitialCurrency {

    /// Picks the currency the amount input should start on. Falls back to `defaultCurrency` when
    /// the preferred one has no usable rate, so `validityCheck` is never entered on a currency we
    /// can't convert — which divides by a zero rate and surfaces a misleading `.tooBig`. The picker
    /// already filters unusable currencies, so this closes the only remaining entry point: a broken
    /// currency restored from a previous amount (e.g. the user's primary while its rate is down).
    static func resolve(
        preferred: Currency?,
        default defaultCurrency: Currency,
        window: NewopExchangeRateWindow
    ) -> Currency {
        guard let preferred, preferred.hasValidRate(in: window) else {
            return defaultCurrency
        }
        return preferred
    }

}
