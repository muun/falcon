//
//  NewOpStates.swift
//  falcon
//
//  Created by Manu Herrera on 13/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

protocol NewOperationStateDelegate { }

protocol NewOperationStateLoaded: NewOperationStateDelegate {
    var type: PaymentRequestType { get }
    var feeInfo: FeeInfo { get }
    var user: User { get }
}

protocol NewOperationStateAmount: NewOperationStateLoaded {
    var amount: BitcoinAmount { get }
}

protocol NewOperationStateDescription: NewOperationStateAmount {
    var description: String { get }
}

protocol NewOpState {}

enum ToAddressState: NewOpState {
    case loading(_ data: NewOpToAddressData.Loading)
    case amount(_ data: NewOpToAddressData.Amount)
    case description(_ data: NewOpToAddressData.Description)
    case confirmation(_ data: NewOpToAddressData.Confirm)

    case feeEditor(_ data: NewOpToAddressData.Confirm, calculateFee: FeeEditor.CalculateFee)
    case currencyPicker(_ data: NewOpToAddressData.Amount)
}

enum SubmarineSwapState: NewOpState {
    case loading(_ data: NewOpSubmarineSwapData.Loading)
    case amount(_ data: NewOpSubmarineSwapData.Amount)
    case description(_ data: NewOpSubmarineSwapData.Description)
    case confirmation(_ data: NewOpSubmarineSwapData.Confirm)

    case currencyPicker(_ data: NewOpSubmarineSwapData.Amount)
}

extension NewOperationStateAmount {

    private func amountInInput(satoshis: Satoshis) -> MonetaryAmount {
        let currency = amount.inInputCurrency.currency
        return satoshis.valuation(at: rate(for: currency), currency: currency)
    }

    private func amountInPrimary(satoshis: Satoshis) -> MonetaryAmount {
        let currency = amount.inPrimaryCurrency.currency
        return satoshis.valuation(at: rate(for: currency), currency: currency)
    }

    private func rate(for currency: String) -> Decimal {
        do {
            return try feeInfo.exchangeRateWindow.rate(for: currency)
        } catch { Logger.fatal(error: error) }
    }

    func toBitcoinAmount(satoshis: Satoshis) -> BitcoinAmount {
        let inInput = amountInInput(satoshis: satoshis)
        let inPrimary = amountInPrimary(satoshis: satoshis)
        return BitcoinAmount(inSatoshis: satoshis, inInputCurrency: inInput, inPrimaryCurrency: inPrimary)
    }

}
