//
//  FeeHelper.swift
//  falcon
//
//  Created by Manu Herrera on 21/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import core

struct Fee {
    let feeRate: FeeRate?
    let state: FeeState
    let isValid: Bool
}

struct FeeHelper {

    static func amountInInput(satoshis: Satoshis, data: NewOperation.ConfirmData) -> MonetaryAmount {
        let currency = data.amount.inInputCurrency.currency
        return satoshis.valuation(at: rate(for: currency, data: data), currency: currency)
    }

    static func amountInPrimary(satoshis: Satoshis, data: NewOperation.ConfirmData) -> MonetaryAmount {
        let currency = data.amount.inPrimaryCurrency.currency
        return satoshis.valuation(at: rate(for: currency, data: data), currency: currency)
    }

    static func rate(for currency: String, data: NewOperation.ConfirmData) -> Decimal {
        do {
            return try data.exchangeRateWindow.rate(for: currency)
        } catch { Logger.fatal(error: error) }
    }

    static func apply(fee: Fee, in data: NewOperation.ConfirmData) -> NewOperation.ConfirmData {

        guard let feeAmount = fee.state.getFeeAmount() else {
            Logger.fatal("Invalid fee state")
        }

        let feeInSatoshis = feeAmount.inSatoshis
        let feeInInput = amountInInput(satoshis: feeInSatoshis, data: data)
        let feeInPrimary = amountInPrimary(satoshis: feeInSatoshis, data: data)

        var state = FeeState.finalFee(BitcoinAmount(inSatoshis: feeInSatoshis,
                                                    inInputCurrency: feeInInput,
                                                    inPrimaryCurrency: feeInPrimary))

        var isValid = true
        var updatedRequest = data.request

        if data.takeFeeFromAmount {
            let finalAmountInSatoshis = data.feeCalculator.totalBalance() - feeInSatoshis
            if finalAmountInSatoshis <= Satoshis(value: 0) {
                state = FeeState.feeNeedsChange
                isValid = false
            } else {
                let finalAmountInInput = amountInInput(satoshis: finalAmountInSatoshis, data: data)
                let finalAmountInPrimary = amountInPrimary(satoshis: finalAmountInSatoshis, data: data)
                let finalAmount = BitcoinAmount(inSatoshis: finalAmountInSatoshis,
                                                inInputCurrency: finalAmountInInput,
                                                inPrimaryCurrency: finalAmountInPrimary)

                updatedRequest = PaymentRequest(type: data.request.type,
                                                amount: finalAmount,
                                                description: data.request.description)
            }
        }

        return NewOperation.ConfirmData(request: updatedRequest,
                                        exchangeRateWindow: data.exchangeRateWindow,
                                        feeWindow: data.feeWindow,
                                        feeCalculator: data.feeCalculator,
                                        fee: Fee(feeRate: fee.feeRate, state: state, isValid: isValid),
                                        takeFeeFromAmount: data.takeFeeFromAmount)
    }

    static func calculateFee(data: NewOperation.ConfirmData, target: UInt) -> Fee {
        return calculateFee(data: data,
                            feeRate: data.feeCalculator.getMinimumFeeRate(confirmationTarget: target))
    }

    static func calculateFee(data: NewOperation.ConfirmData, feeRate: FeeRate) -> Fee {
        let amount = data.amount
        var feeInSatoshis = Satoshis(value: 0)
        var validFee = false

        do {
            feeInSatoshis = try data.feeCalculator.feeFor(amount: amount.inSatoshis,
                                                          feeRate: feeRate,
                                                          takeFeeFromAmount: data.takeFeeFromAmount)
            if data.takeFeeFromAmount {
                validFee = data.feeCalculator.totalBalance() - feeInSatoshis > Satoshis.dust
            } else {
                validFee = data.amount.inSatoshis + feeInSatoshis <= data.feeCalculator.totalBalance()
                    && data.amount.inSatoshis > Satoshis.dust
            }
        } catch {
            do {
                // If we cannot get a fee for a block, it means we didnt have enough balance.
                // We calculate it anyways for UI purposes
                feeInSatoshis = try data.feeCalculator.feeFor(amount: amount.inSatoshis,
                                                              feeRate: feeRate,
                                                              takeFeeFromAmount: true)
                validFee = false
            } catch {
                // This means that we couldnt calculate the fee even taking it from the amount.
                // That could onyl happen if size progression were empty, or if houston were sending corrupted data
                Logger.fatal("No fee possible for satoshis: \(amount.inSatoshis)")
            }
        }

        let feeInInput = FeeHelper.amountInInput(satoshis: feeInSatoshis, data: data)
        let feeInPrimary = FeeHelper.amountInPrimary(satoshis: feeInSatoshis, data: data)
        let fee = BitcoinAmount(inSatoshis: feeInSatoshis,
                                inInputCurrency: feeInInput,
                                inPrimaryCurrency: feeInPrimary)

        return Fee(feeRate: feeRate, state: .finalFee(fee), isValid: validFee)
    }

    static func getFeeLoggingParams(data: NewOperation.ConfirmData) -> [String: String] {
        let fastFee = data.feeWindow.targetedFees[Constant.TargetedBlocks.fast.target]
        let mediumFee = data.feeWindow.targetedFees[Constant.TargetedBlocks.medium.target]
        let slowFee = data.feeWindow.targetedFees[Constant.TargetedBlocks.slow.target]

        var params = [String: String]()

        guard let feeRate = data.fee.feeRate else {
            return params
        }

        switch feeRate.satsPerVByte {
        case fastFee?.satsPerVByte:
            params["fee_type"] = "fast"
        case mediumFee?.satsPerVByte:
            params["fee_type"] = "medium"
        case slowFee?.satsPerVByte:
            params["fee_type"] = "slow"
        default:
            params["fee_type"] = "custom"
        }

        params["satsPerVByte"] = "\(feeRate.satsPerVByte)"

        return params
    }
}
