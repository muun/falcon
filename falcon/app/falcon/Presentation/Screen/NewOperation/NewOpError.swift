//
//  NewOpError.swift
//  falcon
//
//  Created by Federico Bond on 17/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import core

// swiftlint:disable cyclomatic_complexity
enum NewOpError: ErrorViewModel {
    case invalidAddress(_ input: String)
    case expiredInvoice, exchangeRateWindowTooOld
    // Swaps
    case invalidInvoice, invoiceExpiresTooSoon, invoiceAlreadyUsed, noPaymentRoute, invoiceMissingAmount
    case invoiceUnreachableNode, cyclicalSwap
    // Fees
    case insufficientFunds(amountPlusFee: String, maxBalance: String)
    case amountBelowDust
    case unexpected

    func title() -> String {
        switch self {
        case .invalidAddress: return L10n.NewOpError.s2
        case .expiredInvoice: return L10n.NewOpError.s3
        case .exchangeRateWindowTooOld: return L10n.NewOpError.s4
        case .invalidInvoice: return L10n.NewOpError.s5
        case .invoiceExpiresTooSoon: return L10n.NewOpError.s6
        case .invoiceAlreadyUsed: return L10n.NewOpError.s7
        case .noPaymentRoute: return L10n.NewOpError.s8
        case .insufficientFunds: return L10n.NewOpError.s9
        case .amountBelowDust: return L10n.NewOpError.s10
        case .invoiceMissingAmount: return L10n.NewOpError.s11
        case .unexpected: return L10n.NewOpError.s12
        case .invoiceUnreachableNode: return L10n.NewOpError.s13
        case .cyclicalSwap: return L10n.NewOpError.s13
        }
    }

    func description() -> NSAttributedString {
        switch self {
        case .invalidAddress:
            return L10n.NewOpError.s25
                .attributedForDescription(alignment: .center)
        case .expiredInvoice:
            return L10n.NewOpError.s15
                .attributedForDescription(alignment: .center)
        case .exchangeRateWindowTooOld:
            return L10n.NewOpError.s26
                .attributedForDescription(alignment: .center)
        case .invalidInvoice:
            return L10n.NewOpError.s16
                .attributedForDescription(alignment: .center)
        case .invoiceExpiresTooSoon:
            return L10n.NewOpError.s27
                .attributedForDescription(alignment: .center)
        case .invoiceAlreadyUsed:
            return L10n.NewOpError.s28
                .attributedForDescription(alignment: .center)
        case .noPaymentRoute:
            return L10n.NewOpError.s29
                .attributedForDescription(alignment: .center)
                .set(underline: L10n.NewOpError.s17, color: Asset.Colors.muunBlue.color)
        case .insufficientFunds:
            return L10n.NewOpError.s18
                .attributedForDescription(alignment: .center)
        case .amountBelowDust:
            let text = L10n.NewOpError.s30(Satoshis.dust.asDecimal().stringValue())
                .attributedForDescription(alignment: .center)
            return text
        case .invoiceMissingAmount:
            return L10n.NewOpError.s19
                .attributedForDescription(alignment: .center)
        case .unexpected:
            return L10n.NewOpError.s31
                .attributedForDescription(alignment: .center)
                .set(underline: L10n.NewOpError.s17, color: Asset.Colors.muunBlue.color)
        case .invoiceUnreachableNode:
            return L10n.NewOpError.s32
                .attributedForDescription(alignment: .center)
        case .cyclicalSwap:
            return L10n.NewOpError.s21
                .attributedForDescription(alignment: .center)
        }
    }
    // swiftlint:enable function_body_length

    func firstBoxTexts() -> (title: String, content: NSAttributedString)? {
        switch self {
        case .invalidAddress(let input):
            let attText = input.attributedForDescription(alignment: .center)
                .set(bold: input, color: Asset.Colors.title.color)
            return (L10n.NewOpError.s22, attText)
        case .insufficientFunds(let amountPlusFee, _):
            let attText = amountPlusFee.attributedForDescription(alignment: .center)
                .set(bold: amountPlusFee, color: Asset.Colors.title.color)
            return (L10n.NewOpError.s23, attText)
        case .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon, .invoiceAlreadyUsed, .noPaymentRoute,
             .amountBelowDust, .exchangeRateWindowTooOld, .invoiceMissingAmount, .unexpected,
             .invoiceUnreachableNode, .cyclicalSwap:
            return nil
        }
    }

    func secondBoxTexts() -> (title: String, content: NSAttributedString)? {
        switch self {
        case .insufficientFunds(_, let balance):
            let attText = balance.attributedForDescription(alignment: .center)
                .set(bold: balance, color: Asset.Colors.muunRed.color)
            return (L10n.NewOpError.s24, attText)
        case .invalidAddress, .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon, .invoiceAlreadyUsed,
             .noPaymentRoute, .amountBelowDust, .exchangeRateWindowTooOld, .invoiceMissingAmount,
             .unexpected, .invoiceUnreachableNode, .cyclicalSwap:
            return nil
        }
    }

    func loggingName() -> String {
        switch self {
        case .invalidAddress: return "invalid_address"
        case .expiredInvoice: return "expired_invoice"
        case .invalidInvoice: return "invalid_invoice"
        case .invoiceExpiresTooSoon: return "invoice_expires_too_soon"
        case .invoiceAlreadyUsed: return "invoice_already_used"
        case .noPaymentRoute: return "no_payment_route"
        case .insufficientFunds: return "insufficient_funds"
        case .amountBelowDust: return "amount_below_dust"
        case .exchangeRateWindowTooOld: return "exchange_rate_window_too_old"
        case .invoiceMissingAmount: return "invoice_missing_amount"
        case .unexpected: return "other"
        case .invoiceUnreachableNode: return "invoice_unreachable_node"
        case .cyclicalSwap: return "cyclical_swap"
        }
    }

    func secondaryButtonText() -> String {
        return L10n.ErrorView.goToHome
    }
}
// swiftlint:enable cyclomatic_complexity
