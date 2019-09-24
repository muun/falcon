//
//  FeeCalculator.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public enum FeeError: Error {
    case useSmallerFee
    case amountTooSmall
    case insufficientBalance
    case noFeeForConfirmationTarget
}

public class FeeCalculator {

    let targetedFees: [UInt: FeeRate]
    let sizeProgression: [SizeForAmount]

    public init(targetedFees: [UInt: FeeRate], sizeProgression: [SizeForAmount]) {
        self.targetedFees = targetedFees
        self.sizeProgression = sizeProgression
    }

    public func calculateMinimumFee() -> Satoshis {
        // Minimum fee is set to 1 sat/vByte
        let feeRate = FeeRate(satsPerWeightUnit: Constant.minimumFeePerVByte)
        return feeRate.calculateFee(sizeInWeightUnit: sizeProgression.last!.sizeInBytes)
    }

    public func totalBalance() -> Satoshis {
        if let lastItem = sizeProgression.last {
            return lastItem.amountInSatoshis
        }

        Logger.fatal("Size progression must have at least one element by this point")
    }

    public func feeFor(amount: Satoshis, confirmationTarget: UInt, takeFeeFromAmount: Bool = false) throws -> Satoshis {
        let feeRate = getMinimumFeeRate(confirmationTarget: confirmationTarget)

        return try feeFor(amount: amount, feeRate: feeRate, takeFeeFromAmount: takeFeeFromAmount)
    }

    public func feeFor(amount: Satoshis, feeRate: FeeRate, takeFeeFromAmount: Bool = false) throws -> Satoshis {

        if amount < Satoshis.dust {
            throw MuunError(FeeError.amountTooSmall)
        }

        for size in sizeProgression {
            if amount > size.amountInSatoshis {
                continue
            }

            let fee = feeRate.calculateFee(sizeInWeightUnit: size.sizeInBytes)

            if takeFeeFromAmount {
                // If its take fee from amount, return the fee for the last progression
                if let last = sizeProgression.last?.amountInSatoshis, size.amountInSatoshis == last {
                    return fee
                }
            } else {
                // We need to have enough to cover the fee too
                if amount + fee <= size.amountInSatoshis {
                    return fee
                }
            }
        }

        throw MuunError(FeeError.insufficientBalance)
    }

    public func isAmountPayable(_ amount: Satoshis) -> Bool {
        return amount + calculateMinimumFee() <= totalBalance()
    }

    public func shouldTakeFeeFromAmount(_ amount: Satoshis) -> Bool {
        // We only take fee from amount if the amount is equal to the total balance
        return amount == totalBalance()
    }

    public func calculateMaximumFeePossible(amount: Satoshis) -> FeeRate {
        guard let maxSizeProgression = sizeProgression.last else {
            Logger.fatal("No last item in progression")
        }
        let restInSatoshis = totalBalance() - amount
        let satsPerWeightUnit = restInSatoshis.asDecimal() / Decimal(maxSizeProgression.sizeInBytes)
        return FeeRate(satsPerWeightUnit: satsPerWeightUnit)
    }

    public func nextHighestBlock(for feeRate: FeeRate) -> UInt? {
        return targetedFees
            .filter { $0.value.satsPerVByte <= feeRate.satsPerVByte }
            .keys
            .min()
    }

}

extension FeeCalculator {

    /**
     * Get the minimum available fee rate that will hit a given confirmation target. We make no
     * guesses (no averages or interpolations), so we might overshoot the fee if data is too sparse.
     */
    public func getMinimumFeeRate(confirmationTarget: UInt) -> FeeRate {

        // Walk the available targets backwards, finding the highest target below the given one:
        for target in stride(from: confirmationTarget, to: 0, by: -1) {
            if let feeRate = targetedFees[target] {
                // Found! This is the lowest fee rate that hits the given target.
                return feeRate
            }
        }

        // No result? This is illogical. We should ALWAYS have at least the 1 block confirmation target
        Logger.fatal(error: MuunError(FeeError.noFeeForConfirmationTarget))
    }

}