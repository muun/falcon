//
//  NewOpError.swift
//  falcon
//
//  Created by Federico Bond on 17/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation

// swiftlint:disable cyclomatic_complexity
enum NewOpError: ErrorViewModel, Error {
    case invalidAddress(_ input: String)
    case expiredInvoice, exchangeRateWindowTooOld
    // Swaps
    case invalidInvoice, invoiceExpiresTooSoon, invoiceAlreadyUsed, noPaymentRoute,
         invoiceMissingAmount, swapFailed
    case invoiceUnreachableNode, cyclicalSwap, invalidSwap
    // Fees
    case insufficientFunds(amountPlusFee: String, maxBalance: String)
    case amountBelowDust
    case unexpected(error: Error?)

    // Nfc TODO: NFC error handling will move out of NewOpError. Errors
    // coming from the security card flow don't really belong here; they
    // should be modeled and presented by that flow, separately from
    // new operation errors.
    case nfcError(description: String, isRetryable: Bool)

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
        case .swapFailed: return L10n.NewOpError.s14
        case .invalidSwap: return L10n.NewOpError.s12
        case .nfcError: return "Error reading security card"
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
        case .swapFailed:
            return L10n.NewOpError.s33
                .attributedForDescription(alignment: .center)
        case .invalidSwap:
            return L10n.NewOpError.s31
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
        case .nfcError(let description, _):
            return description.attributedForDescription(alignment: .center)
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
        case .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon, .invoiceAlreadyUsed,
             .noPaymentRoute, .swapFailed, .amountBelowDust, .exchangeRateWindowTooOld,
             .invoiceMissingAmount, .unexpected, .invoiceUnreachableNode, .cyclicalSwap,
             .invalidSwap, .nfcError:
            return nil
        }
    }

    func secondBoxTexts() -> (title: String, content: NSAttributedString)? {
        switch self {
        case .insufficientFunds(_, let balance):
            let attText = balance.attributedForDescription(alignment: .center)
                .set(bold: balance, color: Asset.Colors.muunRed.color)
            return (L10n.NewOpError.s24, attText)
        case .invalidAddress, .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon,
             .invoiceAlreadyUsed, .noPaymentRoute, .swapFailed, .amountBelowDust,
             .exchangeRateWindowTooOld, .invoiceMissingAmount, .unexpected,
             .invoiceUnreachableNode, .cyclicalSwap, .invalidSwap, .nfcError:
            return nil
        }
    }

    func analyticsEvent() -> AnalyticsEvent {
        switch self {
        case .invalidAddress:
            return ScreenNewOpErrorEvent(type: .invalidAddress, error: self)
        case .expiredInvoice:
            return ScreenNewOpErrorEvent(type: .expiredInvoice, error: self)
        case .invalidInvoice:
            return ScreenNewOpErrorEvent(type: .invalidInvoice, error: self)
        case .invoiceExpiresTooSoon:
            return ScreenNewOpErrorEvent(type: .invoiceExpiresTooSoon, error: self)
        case .invoiceAlreadyUsed:
            return ScreenNewOpErrorEvent(type: .invoiceAlreadyUsed, error: self)
        case .noPaymentRoute:
            return ScreenNewOpErrorEvent(type: .noPaymentRoute, error: self)
        case .swapFailed:
            return ScreenNewOpErrorEvent(type: .swapFailed, error: self)
        case .invalidSwap:
            return ScreenNewOpErrorEvent(type: .invalidSwap, error: self)
        case .insufficientFunds:
            return ScreenNewOpErrorEvent(type: .insufficientFunds, error: self)
        case .amountBelowDust:
            return ScreenNewOpErrorEvent(type: .amountBelowDust, error: self)
        case .exchangeRateWindowTooOld:
            return ScreenNewOpErrorEvent(type: .exchangeRateWindowTooOld, error: self)
        case .invoiceMissingAmount:
            return ScreenNewOpErrorEvent(type: .invoiceMissingAmount, error: self)
        case .unexpected(let error):
            return ScreenNewOpErrorEvent(type: .other, error: error ?? self)
        case .invoiceUnreachableNode:
            return ScreenNewOpErrorEvent(type: .invoiceUnreachableNode, error: self)
        case .cyclicalSwap:
            return ScreenNewOpErrorEvent(type: .cyclicalSwap, error: self)
        case .nfcError:
            return ScreenNewOpErrorEvent(type: .nfcError, error: self)
        }
    }

    func secondaryButtonText() -> String {
        return L10n.ErrorView.goToHome
    }

    func kind() -> ErrorViewKind {
        switch self {
        case .nfcError(_, let isRetryable):
            return isRetryable ? .retryable : .final
        default:
            return .final
        }
    }
}
// swiftlint:enable cyclomatic_complexity

extension NewOpError: ClassifiedError {
    var classification: ErrorClassification {
        switch self {
        case .invalidAddress, .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon,
             .invoiceAlreadyUsed, .invoiceMissingAmount, .cyclicalSwap,
             .insufficientFunds, .amountBelowDust, .nfcError:
            return .expected
        case .unexpected, .invalidSwap, .noPaymentRoute, .swapFailed,
             .invoiceUnreachableNode, .exchangeRateWindowTooOld:
            return .unexpected
        }
    }
}
