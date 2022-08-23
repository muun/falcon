//
//  NewOpData.swift
//  falcon
//
//  Created by Manu Herrera on 14/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core
import Libwallet

enum NewOpData {

    struct Loading: NewOperationStateDelegate {
        let type: PaymentIntent
    }

    struct Amount: NewOperationStateLoaded {
        let type: PaymentRequestType
        let amount: BitcoinAmount
        let primaryCurrency: String
        let selectedCurrency: Currency
        let totalBalance: BitcoinAmount

        let exchangeRateWindow: NewopExchangeRateWindow

        func rate(for currency: String) -> Decimal {
            return Decimal(exchangeRateWindow.rate(currency))
        }
    }

    struct Description: NewOperationStateAmount {
        let amount: BitcoinAmountWithSelectedCurrency
        let description: String
        let type: PaymentRequestType
        let primaryCurrency: String
        let totalBalance: BitcoinAmount

        let isOneConf: Bool

        let exchangeRateWindow: NewopExchangeRateWindow

        func rate(for currency: String) -> Decimal {
            return Decimal(exchangeRateWindow.rate(currency))
        }
    }

    struct Confirm: NewOperationStateAmount {
        let type: PaymentRequestType
        let amount: BitcoinAmountWithSelectedCurrency
        let total: BitcoinAmount
        let description: String
        let feeState: FeeState
        let takeFeeFromAmount: Bool
        let primaryCurrency: String
        let totalBalance: BitcoinAmount

        let isOneConf: Bool
        let debtType: DebtType?

        let exchangeRateWindow: NewopExchangeRateWindow
        let feeWindow: NewopFeeWindow
        let minMempoolFeeRate: FeeRate

        func rate(for currency: String) -> Decimal {
            return Decimal(exchangeRateWindow.rate(currency))
        }
    }

    struct FeeEditor {
        let type: PaymentRequestType
        let amount: BitcoinAmountWithSelectedCurrency
        let total: BitcoinAmount
        let feeState: FeeState
        let takeFeeFromAmount: Bool
        let primaryCurrency: String
        let totalBalance: BitcoinAmount

        let feeWindow: NewopFeeWindow
        let minMempoolFeeRate: FeeRate

        let calculateFee: (FeeRate) -> NewopFeeState
        let minFeeRate: (UInt) -> FeeRate
        let maxFeeRate: FeeRate

        var feeConfirmationTargets: FeeConfirmationTargets {
            return (
                slow: UInt(feeWindow.slowConfTarget),
                medium: UInt(feeWindow.mediumConfTarget),
                fast: UInt(feeWindow.fastConfTarget)
            )
        }
    }

}
