//
//  ManuallyEnterFeePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 11/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import core

protocol ManuallyEnterFeePresenterDelegate: BasePresenterDelegate {
    func insufficientFunds(maxFee: String)
    func insufficientFunds()
    func feeIsTooHigh(maxFee: String)
    func feeIsTooLow(minFee: String)
    func feeBelowMempoolMinimum(minFee: String)
    func feeIsVeryLow()
    func noWarnings()
}

class ManuallyEnterFeePresenter<Delegate: ManuallyEnterFeePresenterDelegate>: FeeEditorPresenter<Delegate> {

    func calculateMaximumFeePossible() -> FeeRate {
        return maxFeeRate
    }

    func checkWarnings(_ fee: FeeState) {
        let feeRate: FeeRate
        let isValid: Bool

        switch fee {
        case .feeNeedsChange(_, let rate):
            feeRate = rate
            isValid = false

        case .finalFee(_, let rate):
            feeRate = rate
            isValid = true

        case .noPossibleFee:
            return
        }

        let maxFeeRate = core.Constant.FeeProtocol.maxFeeRateAllowed
        if feeRate.satsPerVByte >= maxFeeRate.satsPerVByte {
            delegate.feeIsTooHigh(maxFee: maxFeeRate.stringValue())
            return
        }

        let minProtocolFeeRate = core.Constant.FeeProtocol.minProtocolFeeRate
        let minSatsPerVByte = max(minMempoolFeeRate.satsPerVByte, minProtocolFeeRate.satsPerVByte)

        if feeRate.satsPerVByte < minSatsPerVByte {
            // This fee rate is too low. Is it because it doesn't match current network
            // requirements, or because it's below the protocol-level minimum.
            if minMempoolFeeRate.satsPerVByte > minProtocolFeeRate.satsPerVByte {
                delegate.feeBelowMempoolMinimum(minFee: minSatsPerVByte.stringValue())
                return
            }

            delegate.feeIsTooLow(minFee: minSatsPerVByte.stringValue())
            return
        }

        if !isValid {
            if !takeFeeFromAmount {
                delegate.insufficientFunds(maxFee: calculateMaximumFeePossible().stringValue())
            } else {
                delegate.insufficientFunds()
            }
            return
        }

        let lowFee = minFeeRate(feeConfirmationTargets.slow)

        if feeRate.satsPerVByte < lowFee.satsPerVByte {
            delegate.feeIsVeryLow()
            return
        }

        delegate.noWarnings()
    }
}
