//
//  Operation.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public struct Operation {

    public let id: Int?
    public let requestId: String
    public let isExternal: Bool
    public let direction: OperationDirection

    public let senderProfile: PublicProfile?
    public let senderIsExternal: Bool

    public let receiverProfile: PublicProfile?
    public let receiverIsExternal: Bool
    public let receiverAddress: String?
    public let receiverAddressDerivationPath: String?

    public let amount: BitcoinAmount
    public let fee: BitcoinAmount
    public var confirmations: Int?
    public let exchangeRatesWindowId: Int
    public var description: String?
    public var status: OperationStatus
    public var transaction: Transaction?
    public let creationDate: Date

    public var submarineSwap: SubmarineSwap?

    public let outpoints: [String]? // The complete utxoSet, sorted as used for fee computation

    public let incomingSwap: IncomingSwap?

    public var metadata: OperationMetadataJson?

    public init(id: Int?,
                requestId: String,
                isExternal: Bool,
                direction: OperationDirection,
                senderProfile: PublicProfile?,
                senderIsExternal: Bool,
                receiverProfile: PublicProfile?,
                receiverIsExternal: Bool,
                receiverAddress: String?,
                receiverAddressDerivationPath: String?,
                amount: BitcoinAmount,
                fee: BitcoinAmount,
                confirmations: Int?,
                exchangeRatesWindowId: Int,
                description: String?,
                status: OperationStatus,
                transaction: Transaction?,
                creationDate: Date,
                submarineSwap: SubmarineSwap?,
                outpoints: [String]?,
                incomingSwap: IncomingSwap?,
                metadata: OperationMetadataJson?) {
        self.id = id
        self.requestId = requestId
        self.isExternal = isExternal
        self.direction = direction
        self.senderProfile = senderProfile
        self.senderIsExternal = senderIsExternal
        self.receiverProfile = receiverProfile
        self.receiverIsExternal = receiverIsExternal
        self.receiverAddress = receiverAddress
        self.receiverAddressDerivationPath = receiverAddressDerivationPath
        self.amount = amount
        self.fee = fee
        self.confirmations = confirmations
        self.exchangeRatesWindowId = exchangeRatesWindowId
        self.description = description
        self.status = status
        self.transaction = transaction
        self.creationDate = creationDate
        self.submarineSwap = submarineSwap
        self.outpoints = outpoints
        self.incomingSwap = incomingSwap
        self.metadata = metadata
    }

    // We will define `cancelable` operations with (`isReplaceableByFee` == true && 0 confirmations).
    public func isCancelable() -> Bool {
        return transaction?.isReplaceableByFee ?? false
            && isPending()
    }

    public func isPending() -> Bool {
        return OperationStatus.pendingStates.contains(status)
    }

    // This method returns the sum of the on-chain fee and all the off-chain fees
    public func totalFeeInSatoshis() -> Satoshis {
        return fee.inSatoshis + offChainFeeInSatoshis()
    }

    private func offChainFeeInSatoshis() -> Satoshis {
        if let swap = submarineSwap {
            if let debtType = swap._fundingOutput._debtType, debtType == .LEND {
                return swap._fees?._lightning ?? Satoshis(value: 0) // Lightning off-chain fee or zero for lend swaps
            } else {
                return swap._fees?.total() ?? Satoshis(value: 0) // Sum of all lightning fees or zero
            }
        }

        return Satoshis(value: 0)
    }

    public func isFailedAndOutgoing() -> Bool {
        return status == .FAILED && direction == .OUTGOING
    }
}

public enum OperationDirection: String, Codable {

    /**
     * This Operation was sent to the User.
     */
    case INCOMING

    /**
     * This Operation was sent by the User.
     */
    case OUTGOING

    /**
     * This Operation was to the User, by the same User.
     */
    case CYCLICAL

}

public enum OperationStatus: String, Codable {
    /**
     * Newly created operation, without an associated transaction, or with an unsigned one.
     */
    case CREATED

    /**
     * Operation stored both in the server an on the signing client, in the process of being
     * signed.
     */
    case SIGNING

    /**
     * Operation with an associated transaction, which has been signed but not broadcasted yet.
     */
    case SIGNED

    /**
     * Operation with a transaction that's already been broadcasted, but hasn't confirmed yet.
     */
    case BROADCASTED

    /**
     * For a submarine swap Operation, the on-chain transaction was broadcasted and we're waiting
     * for off-chain payment to succeed.
     */
    case SWAP_PENDING

    /**
     * For a submarine swap Operation, negotiating the channel open with the remote peer.
     */
    case SWAP_OPENING_CHANNEL

    /**
     * For a submarine swap Operation, waiting for a channel to be open in order to start
     * routing the payment.
     */
    case SWAP_WAITING_CHANNEL

    /**
     * For a submarine swap Operation, the off-chain payment was started, but hasn't completed or
     * failed yet.
     */
    case SWAP_ROUTING

    /**
     * For a submarine swap Operation, the off-chain payment was successful, but the swap server has
     * not yet claimed the on-chain funds.
     */
    case SWAP_PAYED

    /**
     * For a submarine swap Operation, the off-chain payment was unsuccessful, and the on-chain
     * funds are time locked.
     */
    case SWAP_FAILED

    /**
     * For a submarine swap Operation, the off-chain payment has expired, and the on-chain funds
     * are the property of the sender again.
     */
    case SWAP_EXPIRED

    /**
     * Operation with its transaction present in a block (0 < confirmations < SETTLEMENT_NUMBER),
     * but not with enough transactions to be settled.
     */
    case CONFIRMED

    /**
     * Operation with its transaction settled (confirmations >= SETTLEMENT_NUMBER).
     */
    case SETTLED

    /**
     * Operation with a transaction that hasn't been present in the last blockchain sync.
     */
    case DROPPED

    /**
     * Operation's transaction was rejected by the network.
     */
    case FAILED

    static let pendingStates: [OperationStatus] = [
        .CREATED, .SIGNING, .SIGNED, .BROADCASTED,
        .SWAP_PENDING, .SWAP_OPENING_CHANNEL,
        .SWAP_WAITING_CHANNEL, .SWAP_ROUTING
    ]

}
