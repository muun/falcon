//
//  FeeCalculatorTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import XCTest
@testable import core
@testable import Muun

class FeeCalculatorTests: MuunTestCase {

    // We use this shourtcut to make it a bit more readable
    let Errors = FeeError.self

    let zeroDebt = Satoshis(value: 0)
    let oneSatoshi = Satoshis(value: 1)
    let defaultFee = Satoshis(value: 10)

    let targetedFees: [UInt: FeeRate] = [1: FeeRate(satsPerVByte: 10),
                                         2: FeeRate(satsPerVByte: 3),
                                         5: FeeRate(satsPerVByte: 1.25),
                                         15: FeeRate(satsPerVByte: 0.5)]
    let highTargetedFees: [UInt: FeeRate] = [1: FeeRate(satsPerVByte: 125),
                                             5: FeeRate(satsPerVByte: 12.15),
                                             15: FeeRate(satsPerVByte: 7.12),
                                             20: FeeRate(satsPerVByte: 5)]

    let defaultProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 103_456), sizeInBytes: 110, outpoint: "default:0", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 20_345_678), sizeInBytes: 230, outpoint: "default:1", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 303_456_789), sizeInBytes: 340, outpoint: "default:2", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 703_456_789), sizeInBytes: 580, outpoint: "default:3", utxoStatus: .CONFIRMED)
    ]

    let negativeProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 48_216), sizeInBytes: 840 , outpoint: "negative:0", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 48_880), sizeInBytes: 1366, outpoint: "negative:1", utxoStatus: .CONFIRMED),
    ]

    let singleNegativeProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 560), sizeInBytes: 840, outpoint: "singleNegative:0", utxoStatus: .CONFIRMED)
    ]

    let dustDrivenProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 1_000), sizeInBytes: 100, outpoint: "dust:0", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 2_000), sizeInBytes: 200, outpoint: "dust:1", utxoStatus: .CONFIRMED),
    ]

    let edgeCaseProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 10_000), sizeInBytes: 90, outpoint: "edge:0", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 20_000), sizeInBytes: 100, outpoint: "edge:1", utxoStatus: .CONFIRMED)
    ]

    let collectProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 9_000), sizeInBytes: 90, outpoint: "collect:0", utxoStatus: .CONFIRMED),
        SizeForAmount(amountInSatoshis: Satoshis(value: 12_000), sizeInBytes: 100, outpoint: "collect:1", utxoStatus: .CONFIRMED)
    ]

    let lendProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 10_000), sizeInBytes: 90, outpoint: "lend:0", utxoStatus: .CONFIRMED)
    ]

    lazy var emptyCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts([], expectedDebt: zeroDebt),
        minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
    )

    lazy var defaultCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(defaultProgression, expectedDebt: zeroDebt),
        minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
    )

    lazy var negativeCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(negativeProgression, expectedDebt: zeroDebt),
        minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
    )

    lazy var singleNegativeCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(singleNegativeProgression, expectedDebt: zeroDebt),
        minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
    )

    lazy var edgeCaseCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(edgeCaseProgression, expectedDebt: zeroDebt),
        minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
    )

    lazy var dustDrivenCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(dustDrivenProgression, expectedDebt: zeroDebt),
        minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
    )

    private func buildNts(_ sizeProgression: [SizeForAmount], expectedDebt: Satoshis) -> NextTransactionSize {
        return NextTransactionSize(
            sizeProgression: sizeProgression,
            validAtOperationHid: nil,
            _expectedDebt: expectedDebt
        )
    }

    func testSmallAmounts() {
        AssertThrowsError(try emptyCalculator.feeFor(amount: Satoshis(value: 0), confirmationTarget: 1), Errors) { err
            in return err == Errors.amountTooSmall
        }

        let almostDust = Satoshis.dust - Satoshis(value: 1)
        AssertThrowsError(try emptyCalculator.feeFor(amount: almostDust, confirmationTarget: 1), Errors) { err in
            return err == Errors.amountTooSmall
        }
    }

    func testZeroBalance() {
        AssertThrowsError(try emptyCalculator.feeFor(amount: Satoshis(value: 10_000), confirmationTarget: 1), Errors)
        { err in
            return err == Errors.insufficientBalance
        }
        AssertThrowsError(
            try emptyCalculator.feeFor(amount: Satoshis(value: 10_000), confirmationTarget: 1, debtType: .LEND), Errors)
        { err in
            return err == Errors.insufficientBalance
        }
    }

    func testInsufficientBalance() {
        let amount = defaultProgression.last!.amountInSatoshis * 2
        AssertThrowsError(try defaultCalculator.feeFor(amount: amount, confirmationTarget: 1), Errors) { err in
            return err == Errors.insufficientBalance
        }
    }

    func testNotEnoughForFee() {
        let amount = defaultProgression.last!.amountInSatoshis - oneSatoshi
        AssertThrowsError(try defaultCalculator.feeFor(amount: amount, confirmationTarget: 1), Errors) { err in
            return err == Errors.insufficientBalance
        }
    }

    func testFeeForDust() {
        let sizeInVBytes = Decimal(defaultProgression[0].sizeInBytes) / 4
        let fee = (defaultFee.asDecimal() * sizeInVBytes) as NSDecimalNumber
        XCTAssertEqual(try defaultCalculator.feeFor(amount: Satoshis.dust, confirmationTarget: 1),
                       .valid(Satoshis(value: fee.int64Value), rate: targetedFees[1]!))
    }

    func testFeeForSize() {
        for size in defaultProgression {
            let half = size.amountInSatoshis / 2
            let sizeInVBytes = Decimal(size.sizeInBytes) / 4
            let fee = (defaultFee.asDecimal() * sizeInVBytes) as NSDecimalNumber

            XCTAssertEqual(try defaultCalculator.feeFor(amount: half, confirmationTarget: 1),
                           .valid(Satoshis(value: fee.int64Value), rate: targetedFees[1]!))
        }
    }

    func testFeeForNextSize() {
        for size in defaultProgression.dropLast() {
            let lowerAmount = size.amountInSatoshis - oneSatoshi
            let higherAmount = size.amountInSatoshis + oneSatoshi

            XCTAssertEqual(try defaultCalculator.feeFor(amount: lowerAmount, confirmationTarget: 1),
                           try defaultCalculator.feeFor(amount: higherAmount, confirmationTarget: 1))
        }
    }

    func testSingleOutputSpendable() throws {
        let max = Satoshis(value: 12_345)
        let sizeProgression = [SizeForAmount(amountInSatoshis: max,
                                             sizeInBytes: 400,
                                             outpoint: "max:0",
                                             utxoStatus: .CONFIRMED)]
        let calculator = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(sizeProgression, expectedDebt: zeroDebt),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        let spendableAmount = calculator.totalBalance()
        let feeState = try calculator.feeFor(amount: spendableAmount, confirmationTarget: 1)

        guard case .valid(let fee, let rate) = feeState else {
            XCTFail("Expected valid fee")
            return
        }

        let amountToBeSend = spendableAmount - fee
        let remaining = max - amountToBeSend

        XCTAssertEqual(rate, targetedFees[1]!)
        XCTAssertEqual(spendableAmount, max)
        XCTAssertEqual(fee, remaining)
        XCTAssertEqual(amountToBeSend + fee, max)
    }

    func testAllFunds() throws {
        let lastEntry = defaultProgression.last!
        let totalBalance = lastEntry.amountInSatoshis

        let spendableAmount = defaultCalculator.totalBalance()
        XCTAssertEqual(spendableAmount, totalBalance)

        let feeState = try defaultCalculator.feeFor(amount: spendableAmount, confirmationTarget: 1)

        guard case .valid(let fee, let rate) = feeState else {
            XCTFail("Expected valid fee")
            return
        }

        let amountToBeSend = spendableAmount - fee
        XCTAssertEqual(amountToBeSend + fee, totalBalance)
        XCTAssertEqual(rate, targetedFees[1]!)
    }

    func testAlmostAllFunds() throws {
        let lastEntry = edgeCaseProgression.last!
        let totalBalance = lastEntry.amountInSatoshis
        let spendableAmount = edgeCaseCalculator.totalBalance()
        XCTAssertEqual(spendableAmount, totalBalance)

        // We cant use the fee for 1 block confirmation target but we can use a lower one
        let almostAllFunds = Satoshis(value: 19_900)
        XCTAssertEqual(try edgeCaseCalculator.feeFor(amount: almostAllFunds, confirmationTarget: 1),
                       .invalid(Satoshis(value: 250), rate: targetedFees[1]!))

        let feeState = try edgeCaseCalculator.feeFor(amount: almostAllFunds, confirmationTarget: 2)
        guard case .valid(let fee, let rate) = feeState else {
            XCTFail("Expected valid fee")
            return
        }

        XCTAssertEqual(rate, targetedFees[2]!)
        XCTAssertEqual(fee, Satoshis(value: 75))
    }

    func testUnspendableUTXO() throws {
        let entry = singleNegativeProgression[0]
        let amount = entry.amountInSatoshis

        let spendable = singleNegativeCalculator.totalBalance()
        XCTAssertEqual(spendable, amount)

        AssertThrowsError(try singleNegativeCalculator.feeFor(amount: amount, confirmationTarget: 1), Errors) { err in
            return err == Errors.insufficientBalance
        }
    }

    func testConfirmationTargets() throws {
        let amount = Satoshis(value: 2_042)
        let calculator = FeeCalculator(
            targetedFees: highTargetedFees,
            nts: buildNts(defaultProgression, expectedDebt: zeroDebt),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        let feeFor1BlockConfTarget = try calculator.feeFor(amount: amount, confirmationTarget: 1)
        XCTAssertEqual(feeFor1BlockConfTarget, .valid(Satoshis(value: 3_438), rate: highTargetedFees[1]!)) // (110 / 4) * 125

        let feeFor6BlockConfTarget = try calculator.feeFor(amount: amount, confirmationTarget: 6)
        // This should get the 5 block target since there is no 6 block target = (110 / 4) * 12.15, rounded up
        XCTAssertEqual(feeFor6BlockConfTarget, .valid(Satoshis(value: 335), rate: highTargetedFees[5]!))

        let feeFor15BlockConfTarget = try calculator.feeFor(amount: amount, confirmationTarget: 15)
        // This should get the 15 block target = (110 / 4) * 7.12, rounded up
        XCTAssertEqual(feeFor15BlockConfTarget, .valid(Satoshis(value: 196), rate: highTargetedFees[15]!))
    }

    func testFeeBelowDust() throws {
        let amount = Satoshis(value: 600)

        let feeBelowDust = try dustDrivenCalculator.feeFor(amount: amount, confirmationTarget: 15)
        XCTAssertEqual(feeBelowDust, .valid(Satoshis(value: 13), rate: targetedFees[15]!))
    }

    func testFeeForLendSwap() throws {
        let amount = Satoshis(value: 600)

        let fee = try dustDrivenCalculator.feeFor(amount: amount, confirmationTarget: 15, debtType: .LEND)
        // on-chain fee should be always 0 for lend swaps
        XCTAssertEqual(fee, .valid(Satoshis(value: 0), rate: FeeRate(satsPerVByte: 0)))
    }

    func testNotEnoughBalanceForLendSwap() throws {
        let amount = Satoshis(value: 9_000)
        let calc = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(lendProgression, expectedDebt: Satoshis(value: 2_000)),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        AssertThrowsError(try calc.feeFor(amount: amount, confirmationTarget: 15, debtType: .LEND), Errors) { err in
            return err == Errors.insufficientBalance
        }
    }

    func testFeeForCollectSwap() throws {
        // We need to make sure that for collect swaps the fee calculator uses utxo balance over UI Balance
        let debtInSats = Satoshis(value: 10_000)
        let amount = Satoshis(value: 11_000)
        let calculator = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(collectProgression, expectedDebt: debtInSats),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        let fee = try calculator.feeFor(amount: amount, confirmationTarget: 15, debtType: .COLLECT)
        XCTAssertEqual(fee, .valid(Satoshis(value: 13), rate: targetedFees[15]!))

        // Also assert that the UI Balance is equal to the total balance minus the debt
        XCTAssertEqual(calculator.totalBalance(), collectProgression.last!.amountInSatoshis - debtInSats)
    }

    func testNotEnoughBalanceForSwap() throws {
        // We need to make sure that for collect swaps the fee calculator uses utxo balance over UI Balance
        let debtInSats = Satoshis(value: 12_000)
        let amount = Satoshis(value: 20_000)
        let calc = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(collectProgression, expectedDebt: debtInSats),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        AssertThrowsError(try calc.feeFor(amount: amount, confirmationTarget: 15, debtType: .COLLECT), Errors) { err in
            return err == Errors.insufficientBalance
        }
    }

    func testTakeFeeFromAmountWithDebt() throws {
        let debtInSats = Satoshis(value: 5_000)
        let amount = Satoshis(value: 7_000)
        let calc = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(collectProgression, expectedDebt: debtInSats),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        let fee = try calc.feeFor(amount: amount, confirmationTarget: 15)
        XCTAssertEqual(fee, .valid(Satoshis(value: 12), rate: targetedFees[15]!))
    }

    func testTakeFeeFromAmountWithDebtEdgeCase() throws {
        // This edge case covers a take fee from amount transaction where you can't pay with the 1 conf fee but you can
        // lower it and product a valid output
        let progression = [SizeForAmount(amountInSatoshis: Satoshis(value: 2_000),
                                         sizeInBytes: 300,
                                         outpoint: "prg:0",
                                         utxoStatus: .CONFIRMED)]
        let debtInSats = Satoshis(value: 1_000)
        let amount = Satoshis(value: 1_000)

        let calc = FeeCalculator(
            targetedFees: highTargetedFees,
            nts: buildNts(progression, expectedDebt: debtInSats),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        let fee = try calc.feeFor(amount: amount, confirmationTarget: 1)
        XCTAssertEqual(fee, .invalid(Satoshis(value: 9_375), rate: highTargetedFees[1]!))
    }

    func testTakeFeeFromAmountWithDebtOtherEdgeCase() throws {
        // This edge case covers a take fee from amount where there is no possible fee to complete the transaction
        let progression = [SizeForAmount(amountInSatoshis: Satoshis(value: 2_000),
                                         sizeInBytes: 1_000,
                                         outpoint: "prg:0",
                                         utxoStatus: .CONFIRMED)]
        let debtInSats = Satoshis(value: 1_400)
        let amount = Satoshis(value: 600)

        let calc = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(progression, expectedDebt: debtInSats),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        AssertThrowsError(try calc.feeFor(amount: amount, confirmationTarget: 1), Errors) { err in
            return err == Errors.insufficientBalance
        }
    }

    func testProgression() throws {
        /**
         This is an interesting edge case
         We will use 999 satoshis as amount, so the fee calculator will calculate the fee using 100 bytes in WU (25 vB)
         The confirmation block target 2 says it will take 3 sats/vbyte so the fee should be 75 satoshis (3 * 25).
         Buuuut 999 + 75 is 1074 satoshis, and that is higher than the amount in satoshis for the size (1000).
         So lets go for the next one:
         200 bytes (WU) = 50 vBytes
         50 vBytes tx * 3 sats/byte = 150 sats.
         999 + 150 = 1149. 1149 < 2000.
         So the correct fee will be 150 satoshis
         */

        let fee = try dustDrivenCalculator.feeFor(
            amount: dustDrivenProgression[0].amountInSatoshis - oneSatoshi,
            confirmationTarget: 2
        )

        XCTAssertEqual(fee, .valid(Satoshis(value: 150), rate: targetedFees[2]!))
    }

    func testOutpoints() {
        var outpoints: [String] = []
        defaultProgression.forEach { (size) in
            outpoints.append(size.outpoint ?? "")
        }

        XCTAssert(
            outpoints == defaultCalculator.getOutpoints(),
            "Outpoints calculated should be the same as the ones in the progression"
        )
    }

    func testEmptyOutpoints() {
        let emptyOutpointsCalc = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(
                [SizeForAmount(amountInSatoshis: Satoshis(value: 1000), sizeInBytes: 10, outpoint: nil, utxoStatus: .CONFIRMED)],
                expectedDebt: zeroDebt
            ),
            minFeeRate: Constant.FeeProtocol.minProtocolFeeRate
        )

        XCTAssert(
            nil == emptyOutpointsCalc.getOutpoints(),
            "Outpoints calculated should be the same as the ones in the progression"
        )
    }
}

fileprivate extension Satoshis {

    static func / (lhs: Satoshis, rhs: Int) -> Satoshis {
        return Satoshis(value: lhs.value / Int64(rhs))
    }

}
