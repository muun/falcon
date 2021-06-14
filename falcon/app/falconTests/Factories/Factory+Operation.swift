//
//  Factory+Operation.swift
//  falconTests
//
//  Created by Federico Bond on 14/01/2021.
//  Copyright © 2021 muun. All rights reserved.
//

@testable import core

extension Factory {

    static func operation(status: OperationStatus,
                   direction: OperationDirection = .OUTGOING,
                   isRBF: Bool = false) -> core.Operation {
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
            amount: bitcoinAmount(sats: Satoshis(value: 100000)),
            fee: bitcoinAmount(sats: Satoshis(value: 1000)),
            confirmations: 0,
            exchangeRatesWindowId: 1,
            description: nil,
            status: status,
            transaction: Transaction(hash: "", confirmations: 0, isReplaceableByFee: isRBF),
            creationDate: Date(),
            submarineSwap: submarineSwap(),
            outpoints: nil,
            incomingSwap: nil,
            metadata: nil
        )
    }

    static func pendingIncomingOperation(isRBF: Bool = false) -> core.Operation {
        return operation(status: OperationStatus.pendingStates.randomElement()!,
                         direction: .INCOMING,
                         isRBF: isRBF)
    }

    static func pendingOutgoingOperation() -> core.Operation {
        return operation(status: OperationStatus.pendingStates.randomElement()!,
                         direction: .OUTGOING)
    }

    static func incomingSwapOperation(status: OperationStatus,
                                      incomingSwap: IncomingSwap = incomingSwap()) -> core.Operation {
        return Operation(
            id: 0,
            requestId: "String",
            isExternal: true,
            direction: .INCOMING,
            senderProfile: nil,
            senderIsExternal: true,
            receiverProfile: nil,
            receiverIsExternal: false,
            receiverAddress: nil,
            receiverAddressDerivationPath: nil,
            amount: bitcoinAmount(sats: Satoshis(value: 100000)),
            fee: bitcoinAmount(sats: Satoshis(value: 1000)),
            confirmations: 0,
            exchangeRatesWindowId: 1,
            description: nil,
            status: status,
            transaction: Transaction(hash: "", confirmations: 0, isReplaceableByFee: false),
            creationDate: Date(),
            submarineSwap: nil,
            outpoints: nil,
            incomingSwap: incomingSwap,
            metadata: nil
        )
    }

    static func bitcoinAmount(sats: Satoshis) -> BitcoinAmount {
        return BitcoinAmount(
            inSatoshis: sats,
            inInputCurrency: MonetaryAmount(amount: sats.asDecimal(), currency: "SAT"),
            inPrimaryCurrency: MonetaryAmount(amount: sats.asDecimal(), currency: "SAT")
        )
    }

    static func submarineSwap() -> SubmarineSwap {
        return SubmarineSwap(
            swapUuid: "1234",
            invoice: "",
            receiver: SubmarineSwapReceiver(alias: nil, networkAddresses: [], publicKey: nil),
            fundingOutput: SubmarineSwapFundingOutput(
                scriptVersion: 0,
                outputAddress: "",
                outputAmount: nil,
                confirmationsNeeded: 0,
                userLockTime: nil,
                userRefundAddress: MuunAddress(version: 1, derivationPath: "m/1/2/3", address: ""),
                serverPaymentHashInHex: "",
                serverPublicKeyInHex: "",
                expirationTimeInBlocks: nil,
                userPublicKey: nil,
                muunPublicKey: nil,
                debtType: DebtType.NONE,
                debtAmount: nil
            ),
            fees: SubmarineSwapFees(
                lightning: Satoshis(value: 0),
                sweep: Satoshis(value: 0),
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

    static func incomingSwap(uuid: String = "1234",
                             paymentHash: Data = SecureRandom.randomBytes(count: 32),
                             amount: Satoshis = Satoshis.zero,
                             sphinxPacket: Data? = nil) -> IncomingSwap {
        return IncomingSwap(
            uuid: uuid,
            paymentHash: paymentHash,
            htlc: IncomingSwapHtlc(
                uuid: "1234",
                expirationHeight: 84239,
                fulfillmentFeeSubsidyInSats: Satoshis(value: 0),
                lentInSats: Satoshis(value: 0),
                address: "2MwBMrLW1fCdsroaDYcatg738v8hr85Gk74",
                outputAmountInSatoshis: Satoshis(value: 100000),
                swapServerPublicKey: Data(),
                htlcTx: Data(),
                fulfillmentTx: nil
            ),
            sphinxPacket: sphinxPacket,
            collect: Satoshis(value: 0),
            paymentAmountInSats: amount,
            preimage: nil
        )
    }

    static func incomingSwapFullDebt(uuid: String = "1234",
                                     paymentHash: Data = SecureRandom.randomBytes(count: 32),
                                     amount: Satoshis = Satoshis.zero) -> IncomingSwap {
        return IncomingSwap(
            uuid: uuid,
            paymentHash: paymentHash,
            htlc: nil,
            sphinxPacket: nil,
            collect: Satoshis(value: 0),
            paymentAmountInSats: amount,
            preimage: nil
        )
    }

}
