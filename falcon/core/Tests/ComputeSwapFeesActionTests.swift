//
//  ComputeSwapFeesActionTests.swift
//  core.root-all-notifications-Unit-Tests
//
//  Created by Federico Bond on 08/10/2020.
//

import Foundation
import XCTest
@testable import core

class ComputeSwapFeesActionTests: XCTestCase {

    let zeroDebt = Satoshis(value: 0)
    let oneSatoshi = Satoshis(value: 1)
    let defaultFee = Satoshis(value: 10)

    let targetedFees: [UInt: FeeRate] = [1: FeeRate(satsPerVByte: 10),
                                         2: FeeRate(satsPerVByte: 3),
                                         5: FeeRate(satsPerVByte: 1.25),
                                         15: FeeRate(satsPerVByte: 0.5)]

    let defaultProgression: [SizeForAmount] = [
        SizeForAmount(amountInSatoshis: Satoshis(value: 103_456), sizeInBytes: 110, outpoint: "default:0"),
        SizeForAmount(amountInSatoshis: Satoshis(value: 20_345_678), sizeInBytes: 230, outpoint: "default:1"),
        SizeForAmount(amountInSatoshis: Satoshis(value: 303_456_789), sizeInBytes: 340, outpoint: "default:2"),
        SizeForAmount(amountInSatoshis: Satoshis(value: 703_456_789), sizeInBytes: 580, outpoint: "default:3")
    ]

    lazy var feeCalculator = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(defaultProgression, expectedDebt: zeroDebt)
    )

    lazy var feeCalculatorWithDebt = FeeCalculator(
        targetedFees: targetedFees,
        nts: buildNts(defaultProgression, expectedDebt: Satoshis(value: 500))
    )

    private func buildNts(_ sizeProgression: [SizeForAmount], expectedDebt: Satoshis) -> NextTransactionSize {
        return NextTransactionSize(
            sizeProgression: sizeProgression,
            validAtOperationHid: nil,
            _expectedDebt: expectedDebt
        )
    }

    lazy var feeWindow = FeeWindow(id: 1, fetchDate: Date(), targetedFees: targetedFees, fastConfTarget: 1, mediumConfTarget: 2, slowConfTarget: 5)

    let exchangeRateWindow = ExchangeRateWindow(id: 1, fetchDate: Date(), rates: ["USD": 10000, "BTC": 1])

    let computeSwapFeesAction = ComputeSwapFeesAction()

    private func createSubmarineSwap(
        outputAmount: Satoshis = Satoshis(value: 1000),
        fees: SubmarineSwapFees? = nil,
        bestRouteFees: [BestRouteFees]? = nil,
        fundingOutputPolicies: FundingOutputPolicies? = nil,
        debtType: DebtType = .NONE,
        debtAmount: Satoshis = Satoshis.zero
    ) -> SubmarineSwap {
        return SubmarineSwap(
            swapUuid: "1234-1234-1234",
            invoice: "",
            receiver: SubmarineSwapReceiver(
                alias: "foo",
                networkAddresses: ["foo.ln"],
                publicKey: "1234567890"
            ),
            fundingOutput: SubmarineSwapFundingOutput(
                scriptVersion: 3,
                outputAddress: "1234567890",
                outputAmount: outputAmount,
                confirmationsNeeded: 1,
                userLockTime: 140,
                userRefundAddress: MuunAddress(version: 4, derivationPath: "m/1/2/3", address: "1234567890"),
                serverPaymentHashInHex: "1234567890",
                serverPublicKeyInHex: "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV",
                expirationTimeInBlocks: 360,
                userPublicKey: WalletPublicKey.fromBase58("xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8", on: "m/"),
                muunPublicKey: WalletPublicKey.fromBase58("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ", on: "m/"),
                debtType: debtType,
                debtAmount: debtAmount
            ),
            fees: fees,
            expiresAt: Date(timeIntervalSinceNow: TimeInterval(1000)),
            willPreOpenChannel: false,
            bestRouteFees: bestRouteFees,
            fundingOutputPolicies: fundingOutputPolicies,
            payedAt: nil,
            preimageInHex: nil
        )
    }

    func testUserDefinedSwapAmount() {
        let swap = createSubmarineSwap(
            fees: nil,
            bestRouteFees: [BestRouteFees(_maxCapacityInSat: 10000, _proportionalMillionth: 100, _baseInSat: 1000)],
            fundingOutputPolicies: FundingOutputPolicies(_maximumDebtInSat: 0, _potentialCollectInSat: 0, _maxAmountInSatFor0Conf: 1000)
        )
        let amount = Satoshis(value: 10000)
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: amount, feeInfo: feeInfo)

        switch swapFees {
        case .valid(let params, let fee, let feeRate, let updatedAmount):
            XCTAssertEqual(params.sweepFee, Satoshis(value: 0))
            XCTAssertEqual(params.routingFee, Satoshis(value: 1001))
            XCTAssertEqual(params.debtType, DebtType.NONE)
            XCTAssertEqual(params.debtAmount, Satoshis(value: 0))
            XCTAssertEqual(params.confirmationsNeeded, 1)
            XCTAssertEqual(fee, Satoshis(value: 275))
            XCTAssertEqual(feeRate, FeeRate(satsPerVByte: 10))
            XCTAssertEqual(updatedAmount, Satoshis(value: 10000))
        default:
            XCTFail("expected valid swap fees")
        }
    }

    func testFixedSwapAmount() {
        let swap = createSubmarineSwap(
            fees: SubmarineSwapFees(
                lightning: Satoshis(value: 1001),
                sweep: Satoshis(value: 0),
                channelOpen: Satoshis(value: 0),
                channelClose: Satoshis(value: 0)
            ),
            bestRouteFees: nil,
            fundingOutputPolicies: nil
        )
        let amount = Satoshis(value: 10000)
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: amount, feeInfo: feeInfo)

        switch swapFees {
        case .valid(let params, let fee, let feeRate, let updatedAmount):
            XCTAssertEqual(params.sweepFee, Satoshis(value: 0))
            XCTAssertEqual(params.routingFee, Satoshis(value: 1001))
            XCTAssertEqual(params.debtType, DebtType.NONE)
            XCTAssertEqual(params.debtAmount, Satoshis(value: 0))
            XCTAssertEqual(params.confirmationsNeeded, 1)
            XCTAssertEqual(fee, Satoshis(value: 275))
            XCTAssertEqual(feeRate, FeeRate(satsPerVByte: 10))
            XCTAssertEqual(updatedAmount, Satoshis(value: 10000))
        default:
            XCTFail("expected valid swap fees")
        }
    }

    func testTakeFeeFromAmount() {
        let swap = createSubmarineSwap(
            bestRouteFees: [BestRouteFees(_maxCapacityInSat: 1_000_000_000, _proportionalMillionth: 100, _baseInSat: 1000)],
            fundingOutputPolicies: FundingOutputPolicies(_maximumDebtInSat: 0, _potentialCollectInSat: 0, _maxAmountInSatFor0Conf: 1000)
        )
        let amount = feeCalculator.totalBalance()
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: amount, feeInfo: feeInfo)

        switch swapFees {
        case .valid(let params, let fee, let feeRate, let updatedAmount):
            XCTAssertEqual(params.sweepFee, Satoshis(value: 0))
            XCTAssertEqual(params.routingFee, Satoshis(value: 71338))
            XCTAssertEqual(params.debtType, DebtType.NONE)
            XCTAssertEqual(params.debtAmount, Satoshis(value: 0))
            XCTAssertEqual(params.confirmationsNeeded, 1)
            XCTAssertEqual(fee, Satoshis(value: 1450))
            XCTAssertEqual(feeRate, FeeRate(satsPerVByte: 10))
            XCTAssertEqual(updatedAmount, Satoshis(value: 703_384_001))
        default:
            XCTFail("expected valid swap fees")
        }
    }

    func testTakeFeeFromAmountWithDebt() {
        let swap = createSubmarineSwap(
            bestRouteFees: [BestRouteFees(_maxCapacityInSat: 1_000_000_000, _proportionalMillionth: 100, _baseInSat: 1000)],
            fundingOutputPolicies: FundingOutputPolicies(_maximumDebtInSat: 0, _potentialCollectInSat: 500, _maxAmountInSatFor0Conf: 1000)
        )
        let amount = feeCalculatorWithDebt.totalBalance()
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculatorWithDebt,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: amount, feeInfo: feeInfo)

        switch swapFees {
        case .valid(let params, let fee, let feeRate, let updatedAmount):
            XCTAssertEqual(params.sweepFee, Satoshis(value: 0))
            XCTAssertEqual(params.routingFee, Satoshis(value: 71338))
            XCTAssertEqual(params.debtType, DebtType.COLLECT)
            XCTAssertEqual(params.debtAmount, Satoshis(value: 500))
            XCTAssertEqual(params.confirmationsNeeded, 1)
            XCTAssertEqual(fee, Satoshis(value: 1450))
            XCTAssertEqual(feeRate, FeeRate(satsPerVByte: 10))
            XCTAssertEqual(updatedAmount, Satoshis(value: 703_383_501))
        default:
            XCTFail("expected valid swap fees")
        }
    }

    func testUnpayableTakeFeeFromAmount() {
        let totalBalance = feeCalculator.totalBalance()
        let swap = createSubmarineSwap(
            bestRouteFees: [BestRouteFees(_maxCapacityInSat: 1_000_000_000, _proportionalMillionth: 100, _baseInSat: totalBalance.value)],
            fundingOutputPolicies: FundingOutputPolicies(_maximumDebtInSat: 0, _potentialCollectInSat: 0, _maxAmountInSatFor0Conf: 1000)
        )
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: totalBalance, feeInfo: feeInfo)

        switch swapFees {
        case .invalid(let amountPlusFee):
            XCTAssert(amountPlusFee > totalBalance)
        default:
            XCTFail("expected invalid swap fees")
        }
    }

    func testPayablePartialCollect() {

        let feeCalculator = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(
                [SizeForAmount(amountInSatoshis: Satoshis(value: 21000), sizeInBytes: 209, outpoint: nil)],
                expectedDebt: Satoshis(value: 8000)
            )
        )

        let totalBalance = feeCalculator.totalBalance()
        let lightningFee = Satoshis(value: 1)
        let swap = createSubmarineSwap(
            outputAmount: Satoshis(value: 9000) + lightningFee,
            fees: SubmarineSwapFees(lightning: lightningFee, sweep: Satoshis.zero, channelOpen: Satoshis.zero, channelClose: Satoshis.zero),
            debtType: .COLLECT,
            debtAmount: Satoshis(value: 2000)
        )
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: totalBalance, feeInfo: feeInfo)
        switch swapFees {
        case .invalid(let amountPlusFee):
            XCTAssert(amountPlusFee > totalBalance)
        default:
            XCTFail("expected invalid swap fees")

        }
    }

    func testUnpayablePartialCollect() {

        let feeCalculator = FeeCalculator(
            targetedFees: targetedFees,
            nts: buildNts(
                [SizeForAmount(amountInSatoshis: Satoshis(value: 21000), sizeInBytes: 209, outpoint: nil)],
                expectedDebt: Satoshis(value: 8000)
            )
        )

        let totalBalance = feeCalculator.totalBalance()
        let lightningFee = Satoshis(value: 1)
        let swap = createSubmarineSwap(
            outputAmount: totalBalance + lightningFee,
            fees: SubmarineSwapFees(lightning: lightningFee, sweep: Satoshis.zero, channelOpen: Satoshis.zero, channelClose: Satoshis.zero),
            debtType: .COLLECT,
            debtAmount: Satoshis(value: 2000)
        )
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: totalBalance, feeInfo: feeInfo)
        switch swapFees {
        case .invalid(let amountPlusFee):
            XCTAssert(amountPlusFee > totalBalance)
        default:
            XCTFail("expected invalid swap fees")

        }
    }

    func testAllFundsIsNeverLend() {
        let totalBalance = feeCalculator.totalBalance()

        let swap: SubmarineSwap = createSubmarineSwap(
            bestRouteFees: [BestRouteFees(_maxCapacityInSat: 10000, _proportionalMillionth: 100, _baseInSat: 1000)],
            fundingOutputPolicies: FundingOutputPolicies(
                _maximumDebtInSat: totalBalance.value + 1,
                _potentialCollectInSat: 0,
                _maxAmountInSatFor0Conf: totalBalance.value + 1
            )
        )
        let feeInfo = FeeInfo(
            feeCalculator: feeCalculator,
            feeWindow: feeWindow,
            exchangeRateWindow: exchangeRateWindow
        )

        let swapFees = computeSwapFeesAction.run(swap: swap, amount: totalBalance, feeInfo: feeInfo)
        switch swapFees {
        case .valid(let params, let totalFee, _, let updatedAmount):
            XCTAssertEqual(totalBalance, updatedAmount + totalFee + params.offchainFee)
            XCTAssertEqual(.NONE, params.debtType)
            XCTAssertEqual(0, params.confirmationsNeeded)
            XCTAssertLessThan(updatedAmount, totalBalance)
        default:
            XCTFail("expected invalid swap fees")

        }
    }
}
