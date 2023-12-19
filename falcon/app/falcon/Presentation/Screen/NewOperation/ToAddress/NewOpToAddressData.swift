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
        let onchainFee: BitcoinAmount?
        let feeNeedsChange: Bool
        let routingFeeInSat: Int64?
        let confirmationsNeeded: Int64?
        let debtAmountInSat: Int64?
        let outputAmountInSat: Int64?
        let outputPaddingInSat: Int64?
        let isOneConf: Bool
        let debtType: DebtType?

        let exchangeRateWindow: NewopExchangeRateWindow
        let feeWindow: NewopFeeWindow
        let minMempoolFeeRate: FeeRate

        func rate(for currency: String) -> Decimal {
            return Decimal(exchangeRateWindow.rate(currency))
        }

        func getOnChainAnalyticsParams() -> [String: Any] {
            var params = getBasicAnalyticsParams()

            getFeeParams().forEach {
                params[$0] = $1
            }

            return params
        }

        func getLightningAnalyticsParams() -> [String: Any] {
            var params = getBasicAnalyticsParams()

            routingFeeInSat.map {
                params["routingFeeInSat"] = $0
            }
            params["isOneConf"] = isOneConf
            confirmationsNeeded.map {
                params["confirmationsNeeded"] = $0
            }
            params["debtAmountInSat"] = debtAmountInSat
            params["outputAmountInSat"] = outputAmountInSat
            params["outputPaddingInSat"] = outputPaddingInSat

            if let debtType = debtType {
                params["debtType"] = debtType.rawValue.lowercased()
            }

            return params
        }

        private func getBasicAnalyticsParams() -> [String: Any] {
            var params: [String: Any] = [:]
            params["amount"] = AnalyticsHelper.serialize(amount: amount.bitcoinAmount)
            params["total"] = AnalyticsHelper.serialize(amount: total)
            feeState.getFeeAmount().map {
                params["fee"] = AnalyticsHelper.serialize(amount: $0)
            }
            onchainFee.map {
                params["onchainFee"] = AnalyticsHelper.serialize(amount: $0)
            }
            params["feeNeedsChange"] = feeNeedsChange

            return params
        }

        private func getFeeParams() -> [String: Any] {
            let feeWindow = self.feeWindow
            let fastFee = feeWindow.getTargetedFees(feeWindow.fastConfTarget)
            let mediumFee = feeWindow.getTargetedFees(feeWindow.mediumConfTarget)
            let slowFee = feeWindow.getTargetedFees(feeWindow.slowConfTarget)

            var params = [String: String]()

            switch feeState {
            case .noPossibleFee, .feeNeedsChange:
                return params
            case .finalFee(_, let rate):
                switch (rate.satsPerVByte as NSDecimalNumber).doubleValue {
                case fastFee:
                    params["fee_type"] = "fast"
                case mediumFee:
                    params["fee_type"] = "medium"
                case slowFee:
                    params["fee_type"] = "slow"
                default:
                    params["fee_type"] = "custom"
                }

                params["sats_per_virtual_byte"] = "\(rate.satsPerVByte)"
            }

            return params
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
