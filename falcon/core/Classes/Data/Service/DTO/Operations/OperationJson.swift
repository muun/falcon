//
//  Operation.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

// This is public for the operation extension
public struct OperationJson: Codable {

    let id: Int?
    let requestId: String
    public let isExternal: Bool
    public let direction: OperationDirectionJson

    public let senderProfile: PublicProfileJson?
    let senderIsExternal: Bool

    let receiverProfile: PublicProfileJson?
    let receiverIsExternal: Bool
    let receiverAddress: String?
    let receiverAddressDerivationPath: String?

    public let amount: BitcoinAmountJson
    let fee: BitcoinAmountJson
    let confirmations: Int?
    let exchangeRatesWindowId: Int
    let status: OperationStatusJson
    let transaction: TransactionJson?
    let creationDate: Date

    var outputAmountInSatoshis: Int64?

    // This one is used when creating a new op
    let swapUuid: String?
    // This one is returned by houston
    let swap: SubmarineSwapJson?

    @available(*, deprecated: 0, message: "The encrypted variant sender_metadata must be used")
    var description: String?

    var senderMetadata: String?
    var receiverMetadata: String?

    let outpoints: [String]? // The complete utxoSet, sorted as used for fee computation

    let incomingSwap: IncomingSwapJson?
    var userPublicNoncesHex: [String]?
}

public struct OperationMetadataJson: Codable {
    public let lnurlSender: String?
    public let description: String?
    public let invoice: String?

    public init(lnurlSender: String?, description: String?, invoice: String?) {
        self.lnurlSender = lnurlSender
        self.description = description
        self.invoice = invoice
    }

    public init(description: String?) {
        self.lnurlSender = nil
        self.description = description
        self.invoice = nil
    }
}

public struct UpdateOperationMetadataJson: Codable {
    let receiverMetadata: String
}

public enum OperationDirectionJson: String, Codable {
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

enum OperationStatusJson: String, Codable {
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
}
