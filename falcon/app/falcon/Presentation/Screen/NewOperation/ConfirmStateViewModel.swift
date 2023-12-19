//
//  ConfirmStateViewModel.swift
//  Muun
//
//  Created by Lucas Serruya on 03/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation
import Libwallet
import core

struct ConfirmStateViewModel {
    private let resolved: NewopResolved
    private let amountInfo: NewopAmountInfo
    private let validated: NewopValidated
    private let update: String
    let note: String

    var paymentIntent: NewopPaymentIntent {
        resolved.paymentIntent!
    }

    var totalBalance: BitcoinAmount {
        amountInfo.totalBalance!.adapt()
    }

    var minMempoolFeeRate: FeeRate {
        let minFeeRateInSatsPerVByte = Decimal(resolved.paymentContext!.minFeeRateInSatsPerVByte)
        return FeeRate(satsPerVByte: minFeeRateInSatsPerVByte)
    }

    var primaryCurrency: String {
        resolved.paymentContext!.primaryCurrency
    }

    var exchangeRateWindow: NewopExchangeRateWindow {
        resolved.paymentContext!.exchangeRateWindow!
    }

    var feeWindow: NewopFeeWindow {
        resolved.paymentContext!.feeWindow!
    }

    var onchainFee: BitcoinAmount? {
        // We use swapInfo.onchainFee instead of validated.fee, as the latter includes the
        // off chain fee so it can be show to the user.
        if let swapInfo = validated.swapInfo {
            return swapInfo.onchainFee?.adapt()
        }

        return validated.fee?.adapt()
    }

    var feeNeedsChange: Bool {
        validated.feeNeedsChange
    }

    var routingFeesInSats: Int64? {
        swapFees()?.routingFeeInSat
    }

    var confirmationsNeeded: Int64? {
        swapFees()?.confirmationsNeeded
    }

    var debtAmountInSat: Int64? {
        swapFees()?.debtAmountInSat
    }

    var outputAmountInSat: Int64? {
        swapFees()?.outputAmountInSat
    }

    var outputPaddingInSat: Int64? {
        swapFees()?.outputPaddingInSat
    }

    var feeState: FeeState {
        let fee = validated.fee!.adapt()
        let feeRate = FeeRate(satsPerVByte: Decimal(amountInfo.feeRateInSatsPerVByte))

        if validated.feeNeedsChange && !isLightningPayment() {
            return .feeNeedsChange(displayFee: fee, rate: feeRate)
        } else {
            return .finalFee(fee, rate: feeRate)
        }
    }

    var isOneConf: Bool {
        return isLightningPayment() ? swapInfo()!.isOneConf : false
    }

    var debtType: DebtType? {
        return isLightningPayment() ? DebtType(rawValue: swapInfo()!.swapFees!.debtType) : nil
    }

    var total: BitcoinAmount {
        validated.total!.adapt()
    }

    func getAmount(lastSelectedCurrency: Currency?) -> BitcoinAmountWithSelectedCurrency {
        let amount = amountInfo.amount!.adapt()
        var selectedCurrency = lastSelectedCurrency

        if lastSelectedCurrency == nil {
            let inPrimaryCurrency = totalBalance.inPrimaryCurrency.currency
            selectedCurrency = GetCurrencyForCode().runAssumingCrashPosibility(code: inPrimaryCurrency)
        }

        let btcAmount = BitcoinAmountWithSelectedCurrency(bitcoinAmount: amount,
                                                          selectedCurrency: selectedCurrency!)
        return btcAmount
    }

    static func fromConfirm(state: NewopConfirmState) -> ConfirmStateViewModel {
        return ConfirmStateViewModel(resolved: state.resolved!,
                                     amountInfo: state.amountInfo!,
                                     validated: state.validated!,
                                     update: state.getUpdate(),
                                     note: state.note)
    }

    static func fromConfirmLightning(state: NewopConfirmLightningState) -> ConfirmStateViewModel {
        return ConfirmStateViewModel(resolved: state.resolved!,
                                     amountInfo: state.amountInfo!,
                                     validated: state.validated!,
                                     update: state.getUpdate(),
                                     note: state.note)
    }

    private func swapFees() -> NewopSwapFees? {
        return swapInfo()?.swapFees
    }

    private func swapInfo() -> NewopSwapInfo? {
        return validated.swapInfo
    }

    private func isLightningPayment() -> Bool {
        switch paymentIntent.adapt() {
        case .submarineSwap(_):
            return true
        default:
            return false
        }
    }
}
