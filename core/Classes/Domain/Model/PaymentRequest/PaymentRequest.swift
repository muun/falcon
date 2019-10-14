//
//  PaymentRequest.swift
//  falcon
//
//  Created by Manu Herrera on 07/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public enum PaymentIntent {
    case toContact
    case toAddress(uri: MuunPaymentURI)
    case submarineSwap(invoice: LibwalletInvoice)
    case toHardwareWallet
    case fromHardwareWallet
}

public enum PaymentRequestType {
    case toContact
    case toAddress(uri: MuunPaymentURI)
    case submarineSwap(invoice: LibwalletInvoice, submarineSwap: SubmarineSwap)
    case toHardwareWallet
    case fromHardwareWallet
}

extension PaymentRequestType {

    public func presetAmount() -> Satoshis? {

        switch self {
        case .toAddress(let uri):
            if let amount = uri.amount, amount != 0 {
                return Satoshis.from(bitcoin: amount)
            }

        case .submarineSwap(let invoice, _):
            if let amount = Int64(invoice.milliSat) {
                return Satoshis(value: amount / 1000)
            }

        case .fromHardwareWallet,
             .toHardwareWallet,
             .toContact:
            preconditionFailure()
        }

        return nil
    }

    public func expiresTime() -> Double? {
        switch self {
        case .toAddress(let uri):
            if let expiresTimeString = uri.expiresTime,
                let expiresTime = Double(expiresTimeString) {
                return expiresTime
            }

        case .submarineSwap(let invoice, _):
            if invoice.expiry > 0 {
                return Double(invoice.expiry)
            }

        case .fromHardwareWallet,
             .toContact,
             .toHardwareWallet:
            break
        }

        return nil
    }

    public func presetDescription() -> String? {

        switch self {
        case .toAddress(let uri):
            if let message = uri.message, message != "" {
                return uri.message
            }

        case .submarineSwap(let invoice, _):
            if invoice.description != "" {
                return invoice.description
            }

        case .fromHardwareWallet,
             .toHardwareWallet,
             .toContact:
            preconditionFailure()
        }

        return nil

    }

    public func defaultConfirmationTarget(currentBlockchainHeight: Int) -> UInt {
        switch self {
        case .submarineSwap(_, let swap):
            /*
            For 0-conf payments:
            Clients should choose a fee rate targeting block (swap.user_time_lock - current_blockchain_height) / 4 - 3.
             The minus 3 is to prevent a race condition between the client and server finding out about blocks,
             and also having slightly different values of the fee rates per block target.
             */
            if swap._fundingOutput._confirmationsNeeded == 0 {
                return UInt((swap._fundingOutput._userLockTime - currentBlockchainHeight) / 4 - 3)
            }
            // For non 0-conf, use 1 block as confirmation target:
            return 1
        default:
            // By default, use 1 block as confirmation target:
            return 1
        }
    }

    public func isFeeEditable() -> Bool {
        switch self {
        case .submarineSwap:
            // For submarine swaps, fee wont be editable
            return false
        default:
            return true
        }
    }

    public func willPreOpenChannel() -> Bool {
        switch self {
        case .submarineSwap(_, let submarineSwap):
            return submarineSwap._willPreOpenChannel
        default:
            return false
        }
    }

}

public struct PaymentRequest {
    public let type: PaymentRequestType
    public let amount: BitcoinAmount
    public let description: String

    public init(type: PaymentRequestType, amount: BitcoinAmount, description: String) {
        self.type = type
        self.amount = amount
        self.description = description
    }
}
