//
//  ComputeSwapFeesAction.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 06/10/2020.
//

import Foundation
import Libwallet

public class ComputeSwapFeesAction {

    public enum Result {
        case valid(params: SwapExecutionParameters, totalFee: Satoshis, feeRate: FeeRate, updatedAmount: Satoshis)
        case invalid(amountPlusFee: Satoshis)
    }

    public func run(swap: SubmarineSwap, amount: Satoshis, feeInfo: FeeInfo) -> Result {
        let feeCalculator = feeInfo.feeCalculator
        var params: SwapExecutionParameters
        var fee: Satoshis
        var feeRate: FeeRate
        var updatedAmount = amount

        // Check if swap is of fixed amount (in which case it should have the following optional fields set)
        if let fees = swap._fees,
           let debtType = swap._fundingOutput._debtType,
           let debtAmount = swap._fundingOutput._debtAmount,
           let confirmationsNeeded = swap._fundingOutput._confirmationsNeeded {

            // Swap has amount, compute off-chain fees, sum, then compute on-chain fees
            params = SwapExecutionParameters(
                sweepFee: fees._sweep,
                routingFee: fees._lightning,
                debtType: debtType,
                debtAmount: debtAmount,
                confirmationsNeeded: UInt(confirmationsNeeded)
            )

            let outputAmount = getFinalOutputAmountWithDebt(amount: amount, params: params)

            do {
                (fee, feeRate) = try calculateOnchainFee(
                    outputAmount: outputAmount,
                    confirmationsNeeded: params.confirmationsNeeded,
                    debtType: params.debtType,
                    feeInfo: feeInfo
                )
            } catch {
                let minimumFee = getMinimumFeeInSats(confirmations: params.confirmationsNeeded,
                                                     feeCalculator: feeCalculator)
                return .invalid(amountPlusFee: outputAmount + minimumFee)
            }

            if updatedAmount + params.offchainFee + fee > feeCalculator.totalBalance() {
                return .invalid(amountPlusFee: updatedAmount + params.offchainFee + fee)
            }

        } else {

            // Amount has been chosen by user, check that we have the corresponding optional fields set
            // for computing the fee.
            guard let bestRouteFees = swap._bestRouteFees,
                  let fundingOutputPolicies = swap._fundingOutputPolicies else {
                fatalError("Swap with user chosen amount missing data for computing fees")
            }

            if feeCalculator.shouldTakeFeeFromAmount(amount) {

                // Beware future maintainer! You might say this branch doesn't consider the COLLECT amount
                // BUT the amount is the user balance, not the UTXO balance, so it already has the collectable amount deducted

                // Compute on-chain fees, subtract from amount
                do {
                    (fee, feeRate) = try calculateOnchainFee(
                        outputAmount: amount,
                        confirmationsNeeded: 0,
                        debtType: DebtType.NONE,
                        feeInfo: feeInfo
                    )
                } catch {
                    let minimumFee = getMinimumFeeInSats(confirmations: 0,
                                                         feeCalculator: feeCalculator)
                    return .invalid(amountPlusFee: amount + minimumFee)
                }

                var outputAmount: Satoshis
                var offchainAmount: Satoshis
                (params, outputAmount, offchainAmount) = findParamsForAllFunds(
                    amount: amount,
                    fee: fee,
                    bestRouteFees: bestRouteFees,
                    fundingOutputPolicies: fundingOutputPolicies
                )

                // If we don't qualify for 0-conf, redo the computation with 1-conf
                if params.confirmationsNeeded == 1 {
                    do {
                        (fee, feeRate) = try calculateOnchainFee(
                            outputAmount: amount,
                            confirmationsNeeded: 1,
                            debtType: DebtType.NONE,
                            feeInfo: feeInfo
                        )
                    } catch {
                        let minimumFee = getMinimumFeeInSats(confirmations: 1,
                                                             feeCalculator: feeCalculator)
                        return .invalid(amountPlusFee: outputAmount + minimumFee)
                    }

                    (params, outputAmount, offchainAmount) = findParamsForAllFunds(
                        amount: amount,
                        fee: fee,
                        bestRouteFees: bestRouteFees,
                        fundingOutputPolicies: fundingOutputPolicies
                    )

                }

                // Subtract the on and off-chain fees
                updatedAmount = offchainAmount

                // If the fees are really high, we might end up calculating an negative offchain amount
                let zero = Satoshis(value: 0)
                if offchainAmount < zero {
                    return .invalid(amountPlusFee: zero + params.offchainFee + fee)
                }

            } else {

                // Compute off-chain fees
                params = paramsForUserDefinedAmountSwap(amount: amount,
                                                        bestRouteFees: bestRouteFees,
                                                        fundingOutputPolicies: fundingOutputPolicies)

                let outputAmount = getFinalOutputAmountWithDebt(amount: amount, params: params)

                do {
                    (fee, feeRate) = try calculateOnchainFee(
                        outputAmount: outputAmount,
                        confirmationsNeeded: params.confirmationsNeeded,
                        debtType: params.debtType,
                        feeInfo: feeInfo
                    )
                } catch {
                    let minimumFee = getMinimumFeeInSats(confirmations: params.confirmationsNeeded,
                                                         feeCalculator: feeCalculator)
                    return .invalid(amountPlusFee: outputAmount + minimumFee)
                }
            }
        }

        return .valid(params: params, totalFee: fee, feeRate: feeRate, updatedAmount: updatedAmount)
    }

    private func paramsForUserDefinedAmountSwap(amount: Satoshis,
                                                bestRouteFees: [BestRouteFees],
                                                fundingOutputPolicies: FundingOutputPolicies) -> SwapExecutionParameters {

        let bestRouteFeesList = LibwalletBestRouteFeesList()
        for route in bestRouteFees {
            let elem = LibwalletBestRouteFees()
            elem.maxCapacity = route._maxCapacityInSat
            elem.feeProportionalMillionth = route._proportionalMillionth
            elem.feeBase = route._baseInSat
            bestRouteFeesList.add(elem)
        }

        let policies = LibwalletFundingOutputPolicies()
        policies.maximumDebt = fundingOutputPolicies._maximumDebtInSat
        policies.potentialCollect = fundingOutputPolicies._potentialCollectInSat
        policies.maxAmountFor0Conf = fundingOutputPolicies._maxAmountInSatFor0Conf

        let fees = LibwalletComputeSwapFees(amount.value, bestRouteFeesList, policies)!

        return SwapExecutionParameters(sweepFee: Satoshis(value: fees.sweepFee),
                                       routingFee: Satoshis(value: fees.routingFee),
                                       debtType: DebtType(rawValue: fees.debtType)!,
                                       debtAmount: Satoshis(value: fees.debtAmount),
                                       confirmationsNeeded: UInt(fees.confirmationsNeeded))
    }

    private func getMinimumFeeInSats(confirmations: UInt, feeCalculator: FeeCalculator) -> Satoshis {
        if confirmations == 1 {
            // Minimum fee for 1 conf swaps is the next block fee
            return feeCalculator.calculateMinimumFee(target: 1)
        }
        return feeCalculator.calculateMinimumFee(target: 250)
    }

    private func getFinalOutputAmountWithDebt(amount: Satoshis, params: SwapExecutionParameters) -> Satoshis {
        var outputAmountInSatoshis = amount + params.offchainFee

        // We have to add the COLLECTABLE_AMOUNT to the outputAmountInSatoshis in Collect swaps
        if params.debtType == .COLLECT {
            outputAmountInSatoshis += params.debtAmount
        }

        return outputAmountInSatoshis
    }

    private func calculateOnchainFee(outputAmount: Satoshis,
                                     confirmationsNeeded: UInt,
                                     debtType: DebtType,
                                     feeInfo: FeeInfo) throws -> (Satoshis, FeeRate) {

        let feeCalculator = feeInfo.feeCalculator
        let confirmationTarget: UInt

        if confirmationsNeeded == 0 {
            // Since refunds are instant we can use 250 all the time
            confirmationTarget = 250
        } else {
            // For non 0-conf, use 1 block as confirmation target:
            confirmationTarget = 1
        }

        let fee = try feeCalculator.feeFor(amount: outputAmount,
                                           confirmationTarget: confirmationTarget,
                                           debtType: debtType)

        switch fee {
        case .valid(let fee, let rate):
            return (fee, rate)
        default:
            throw MuunError(FeeError.insufficientBalance)
        }
    }

    func findParamsForAllFunds(amount: Satoshis,
                               fee: Satoshis,
                               bestRouteFees: [BestRouteFees],
                               fundingOutputPolicies: FundingOutputPolicies)
    -> (params: SwapExecutionParameters, outputAmount: Satoshis, offchainAmount: Satoshis) {

        let lendlessPolicies = FundingOutputPolicies(
            _maximumDebtInSat: 0, // No lend for use all funds
            _potentialCollectInSat: fundingOutputPolicies._potentialCollectInSat,
            _maxAmountInSatFor0Conf: fundingOutputPolicies._maxAmountInSatFor0Conf
        )
        let outputAmount = amount - fee

        // Get a first approximation (by excess) of the off-chain fee which we will later refine
        var params = paramsForUserDefinedAmountSwap(
            amount: outputAmount,
            bestRouteFees: bestRouteFees,
            fundingOutputPolicies: lendlessPolicies
        )

        // Find the point at which the off-chain amount (displayed to the user) plus the off-chain
        // fee equals our output amount
        var offchainAmount = outputAmount - params.offchainFee

        while true {
            params = paramsForUserDefinedAmountSwap(
                amount: offchainAmount,
                bestRouteFees: bestRouteFees,
                fundingOutputPolicies: lendlessPolicies
            )
            if offchainAmount + params.offchainFee >= outputAmount {
                break
            }
            offchainAmount += Satoshis(value: 1)
        }

        return (params, outputAmount, offchainAmount)
    }
}
