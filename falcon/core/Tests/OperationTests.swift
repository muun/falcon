//
//  OperationTests.swift
//  falconTests
//
//  Created by Manu Herrera on 21/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest
@testable import core

class OperationTests: XCTestCase {

    func testTotalFeeForOnChainOperations() {
        let onChainFee = Satoshis(value: 1000)

        let incoming = buildBasicOperation(direction: .INCOMING, amount: Satoshis(value: 10000), onChainFee: onChainFee)
        // For incoming on-chain ops, the total fee is the on-chain fee
        assert(incoming.totalFeeInSatoshis() == onChainFee)

        let cyclical = buildBasicOperation(direction: .CYCLICAL, amount: Satoshis(value: 10000), onChainFee: onChainFee)
        // For cyclical on-chain ops, the total fee is the on-chain fee
        assert(cyclical.totalFeeInSatoshis() == onChainFee)
    }

    func testTotalFeeForSubmarineSwaps() {
        let onChainFee = Satoshis(value: 1000)

        let lightningFee = Satoshis(value: 1)
        let sweepFee = Satoshis(value: 10)
        let outgoingLendSwap = buildBasicOperation(
            direction: .OUTGOING,
            amount: Satoshis(value: 10000),
            onChainFee: onChainFee,
            submarineSwap: buildSubmarineSwap(
                lightningFee: lightningFee,
                sweepFee: sweepFee,
                debtType: .LEND
            )
        )
        // For outgoing (LEND) swaps ops, the total fee is the on-chain fee + the lightning fee
        assert(outgoingLendSwap.totalFeeInSatoshis() == onChainFee + lightningFee)

        let outgoingSwap = buildBasicOperation(
            direction: .OUTGOING,
            amount: Satoshis(value: 10000),
            onChainFee: onChainFee,
            submarineSwap: buildSubmarineSwap(
                lightningFee: lightningFee,
                sweepFee: sweepFee,
                debtType: nil
            )
        )
        // For outgoing swaps ops, the total fee is the on-chain fee + the lightning fee + the sweep fee
        assert(outgoingSwap.totalFeeInSatoshis() == onChainFee + lightningFee + sweepFee)
    }

    private func buildBasicOperation(
        direction: OperationDirection,
        amount: Satoshis,
        onChainFee: Satoshis,
        submarineSwap: SubmarineSwap? = nil
    ) -> core.Operation {
        return Operation(
            id: 0,
            requestId: "String",
            isExternal: true,
            direction: direction,
            senderProfile: nil,
            senderIsExternal: true,
            receiverProfile: nil,
            receiverIsExternal: false,
            receiverAddress: nil,
            receiverAddressDerivationPath: nil,
            amount: buildBitcoinAmount(sats: amount),
            fee: buildBitcoinAmount(sats: onChainFee),
            confirmations: 0,
            exchangeRatesWindowId: 1,
            description: nil,
            status: .BROADCASTED,
            transaction: nil,
            creationDate: Date(),
            submarineSwap: submarineSwap,
            outpoints: nil,
            incomingSwap: nil,
            metadata: nil
        )
    }

    private func buildBitcoinAmount(sats: Satoshis) -> BitcoinAmount {
        return BitcoinAmount(
            inSatoshis: sats,
            inInputCurrency: MonetaryAmount(amount: sats.asDecimal(), currency: "SAT"),
            inPrimaryCurrency: MonetaryAmount(amount: sats.asDecimal(), currency: "SAT")
        )
    }

    private func buildSubmarineSwap(lightningFee: Satoshis, sweepFee: Satoshis, debtType: DebtType?) -> SubmarineSwap {

        return SubmarineSwap(
            swapUuid: "",
            invoice: "",
            receiver: SubmarineSwapReceiver(alias: nil, networkAddresses: [], publicKey: nil),
            fundingOutput: SubmarineSwapFundingOutput(
                scriptVersion: 0,
                outputAddress: "",
                outputAmount: nil,
                confirmationsNeeded: nil,
                userLockTime: nil,
                userRefundAddress: nil,
                serverPaymentHashInHex: "",
                serverPublicKeyInHex: "",
                expirationTimeInBlocks: nil,
                userPublicKey: nil,
                muunPublicKey: nil,
                debtType: debtType,
                debtAmount: nil
            ),
            fees: SubmarineSwapFees(
                lightning: lightningFee,
                sweep: sweepFee,
                channelOpen: Satoshis(value: 0),
                channelClose: Satoshis(value: 0)
            ),
            expiresAt: Date(),
            willPreOpenChannel: false,
            bestRouteFees: nil,
            fundingOutputPolicies: nil,
            payedAt: nil,
            preimageInHex: nil
        )
    }

}
