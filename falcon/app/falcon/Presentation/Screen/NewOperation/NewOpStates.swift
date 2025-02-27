//
//  NewOpStates.swift
//  falcon
//
//  Created by Manu Herrera on 13/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation


protocol NewOperationStateDelegate { }

protocol NewOperationStateLoaded: NewOperationStateDelegate {
    var type: PaymentRequestType { get }
    var primaryCurrency: String { get }
    var totalBalance: BitcoinAmount { get }

    func rate(for currency: String) -> Decimal
}

protocol NewOperationStateAmount: NewOperationStateLoaded {
    var amount: BitcoinAmountWithSelectedCurrency { get }
}

protocol NewOperationStateDescription: NewOperationStateAmount {
    var description: String { get }
}

enum NewOpState {
    case loading(_ data: NewOpData.Loading)
    case amount(_ data: NewOpData.Amount)
    case description(_ data: NewOpData.Description)
    case confirmation(_ data: NewOpData.Confirm)

    case feeEditor(_ data: NewOpData.FeeEditor)
    case currencyPicker(_ data: NewOpData.Amount, selectedCurrency: Currency)
}

extension NewOperationStateAmount {

    private func amountInInput(satoshis: Satoshis) -> MonetaryAmount {
        let currency = amount.bitcoinAmount.inInputCurrency.currency
        return satoshis.valuation(at: rate(for: currency), currency: currency)
    }

    private func amountInPrimary(satoshis: Satoshis) -> MonetaryAmount {
        let currency = amount.bitcoinAmount.inPrimaryCurrency.currency
        return satoshis.valuation(at: rate(for: currency), currency: currency)
    }

    func toBitcoinAmount(satoshis: Satoshis) -> BitcoinAmount {
        let inInput = amountInInput(satoshis: satoshis)
        let inPrimary = amountInPrimary(satoshis: satoshis)
        return BitcoinAmount(inSatoshis: satoshis, inInputCurrency: inInput, inPrimaryCurrency: inPrimary)
    }

}
