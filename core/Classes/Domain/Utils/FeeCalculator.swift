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

    public enum Result {
        case valid(_ fee: Satoshis, rate: FeeRate)
        case invalid(_ fee: Satoshis, rate: FeeRate)
    }

    let targetedFees: [UInt: FeeRate]
    let sizeProgression: [SizeForAmount]
    let expectedDebt: Satoshis

    public init(targetedFees: [UInt: FeeRate], sizeProgression: [SizeForAmount], expectedDebt: Satoshis) {
        self.targetedFees = targetedFees
        self.sizeProgression = sizeProgression
        self.expectedDebt = expectedDebt
    }

    public func calculateMinimumFee() -> Satoshis {
        // Minimum fee is set to 1 sat/vByte
        let feeRate = FeeRate(satsPerWeightUnit: Constant.minimumFeePerVByte)
        if let last = sizeProgression.last {
            return feeRate.calculateFee(sizeInWeightUnit: last.sizeInBytes)
        }
        // In case the size progression is empty, we just return 0
        // (This is going to be used in the insufficient funds screen)
        return Satoshis(value: 0)
    }

    public func totalBalance() -> Satoshis {
        if let lastItem = sizeProgression.last {
            // The total balance is calculated by substracting the expectedDebt from the last item in the NTS
            return lastItem.amountInSatoshis - expectedDebt
        }

        return Satoshis(value: 0)
    }

    private func utxoBalance() -> Satoshis {
        return sizeProgression.last?.amountInSatoshis ?? Satoshis(value: 0)
    }

    public func feeFor(amount: Satoshis, confirmationTarget: UInt, debtType: DebtType = .NONE) throws -> Result {
        let feeRate = getMinimumFeeRate(confirmationTarget: confirmationTarget)
        return try feeFor(amount: amount, rate: feeRate, debtType: debtType)
    }

    // swiftlint:disable cyclomatic_complexity
    public func feeFor(amount: Satoshis, rate feeRate: FeeRate, debtType: DebtType = .NONE) throws -> Result {

        if debtType == .LEND {
            // If it's a lend swap, then the 'on-chain' fee won't exist
            let zeroFee = Satoshis(value: 0)
            if isAmountPayable(amount, fee: zeroFee) {
                return .valid(zeroFee, rate: FeeRate(satsPerVByte: 0))
            }

            throw MuunError(FeeError.insufficientBalance)
        }

        if amount < Satoshis.dust {
            throw MuunError(FeeError.amountTooSmall)
        }

        let takeFeeFromAmount = shouldTakeFeeFromAmount(amount)

        for size in sizeProgression {
            if amount > size.amountInSatoshis {
                continue
            }

            let fee = feeRate.calculateFee(sizeInWeightUnit: size.sizeInBytes)

            if takeFeeFromAmount {
                if size.amountInSatoshis - expectedDebt >= fee + Satoshis.dust {
                    // We need to make sure we have enough sats to cover the fee and one output of at least dust
                    return .valid(fee, rate: feeRate)
                } else if size.amountInSatoshis - expectedDebt - calculateMinimumFee() >= Satoshis.dust {
                    // We need to make sure that the payment can produce one output >= dust with the minimum fee
                    return .invalid(fee, rate: feeRate)
                }

                throw MuunError(FeeError.insufficientBalance)
            }

            // We need to have enough to cover the fee too
            if amount + fee <= size.amountInSatoshis {
                if isAmountPayable(amount, fee: fee, debtType) {
                    return .valid(fee, rate: feeRate)
                } else if isAmountPayableWithMinimumFee(amount, debtType) {
                    return .invalid(fee, rate: feeRate)
                }
            }
        }

        if let biggestSize = sizeProgression.last, isAmountPayableWithMinimumFee(amount, debtType) {
            return .invalid(feeRate.calculateFee(sizeInWeightUnit: biggestSize.sizeInBytes), rate: feeRate)
        }

        throw MuunError(FeeError.insufficientBalance)
    }
    // swiftlint:enable cyclomatic_complexity

    // FIXME: minimum fee it's not always the final fee for swaps
    // We should somehow check the confs needed and the routing fee 🤷‍♂️
    private func isAmountPayable(_ sats: Satoshis, fee: Satoshis? = nil, _ debtType: DebtType = .NONE) -> Bool {
        let finalFee = fee ?? calculateMinimumFee()

        if debtType == .COLLECT {
            return sats + finalFee <= utxoBalance()
        }

        return sats + finalFee <= totalBalance()
    }

    public func isAmountPayableWithMinimumFee(_ sats: Satoshis, _ debtType: DebtType = .NONE) -> Bool {
        return isAmountPayable(sats, debtType)
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

extension FeeCalculator.Result: Equatable {

    public static func == (lhs: FeeCalculator.Result, rhs: FeeCalculator.Result) -> Bool {
        switch (lhs, rhs) {
        case (.valid(let lhsFee, let lhsRate), .valid(let rhsFee, let rhsRate)):
            return lhsFee == rhsFee && lhsRate == rhsRate
        case (.invalid(let lhsFee, let lhsRate), .invalid(let rhsFee, let rhsRate)):
            return lhsFee == rhsFee && lhsRate == rhsRate
        default:
            return false
        }
    }
}
