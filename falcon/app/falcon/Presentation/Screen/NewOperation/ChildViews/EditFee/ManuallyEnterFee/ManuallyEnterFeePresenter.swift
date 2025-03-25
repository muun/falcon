//
//  ManuallyEnterFeePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 11/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//



protocol ManuallyEnterFeePresenterDelegate: BasePresenterDelegate {
    func insufficientFunds()
    func feeIsTooHigh(maxFee: FeeRate)
    func feeIsTooLow(minFee: FeeRate)
    func feeBelowMempoolMinimum(minFee: FeeRate)
    func feeIsVeryLow()
    func noWarnings()
}

class ManuallyEnterFeePresenter<Delegate: ManuallyEnterFeePresenterDelegate>: FeeEditorPresenter<Delegate> {

    func checkWarnings(_ fee: FeeState) {
        let feeRate: FeeRate
        let isValid: Bool

        switch fee {
        case .feeNeedsChange(_, let rate):
            feeRate = rate
            isValid = false

        case .finalFee(_, let rate, _):
            feeRate = rate
            isValid = true

        case .noPossibleFee:
            return
        }

        let maxFeeRate = Constant.FeeProtocol.maxFeeRateAllowed
        if feeRate.satsPerVByte >= maxFeeRate.satsPerVByte {
            delegate.feeIsTooHigh(maxFee: maxFeeRate)
            return
        }

        let minProtocolFeeRate = Constant.FeeProtocol.minProtocolFeeRate
        let minSatsPerVByte = max(minMempoolFeeRate.satsPerVByte, minProtocolFeeRate.satsPerVByte)

        if feeRate.satsPerVByte < minSatsPerVByte {
            // This fee rate is too low. Is it because it doesn't match current network
            // requirements, or because it's below the protocol-level minimum.
            if minMempoolFeeRate.satsPerVByte > minProtocolFeeRate.satsPerVByte {
                delegate.feeBelowMempoolMinimum(minFee: FeeRate(satsPerVByte: minSatsPerVByte))
                return
            }

            delegate.feeIsTooLow(minFee: FeeRate(satsPerVByte: minSatsPerVByte))
            return
        }

        if !isValid {
            delegate.insufficientFunds()
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
