//
//  ScreenNewOpErrorEvent.swift
//  falcon
//
//  Created by Federico Jordán on 08/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

struct ScreenNewOpErrorEvent: AnalyticsEvent {
    enum ErrorEventType: String {
        case invalidAddress = "invalid_address"
        case expiredInvoice = "expired_invoice"
        case invalidInvoice = "invalid_invoice"
        case invoiceExpiresTooSoon = "invoice_expires_too_soon"
        case invoiceAlreadyUsed = "invoice_already_used"
        case invoiceMissingAmount = "invoice_missing_amount"
        case noPaymentRoute = "no_payment_route"
        case insufficientFunds = "insufficient_funds"
        case amountBelowDust = "amount_below_dust"
        case exchangeRateWindowTooOld = "exchange_rate_window_too_old"
        case swapFailed = "swap_failed"
        case other
        // NOTE: The following cases are currently not defined in the analytics spreadsheet
        case invoiceUnreachableNode = "invoice_unreachable_node"
        case cyclicalSwap = "cyclical_swap"
        case nfcError = "nfc_error"
    }

    var name: String { "s_new_op_error" }

    var parameters: [String: Any]? {
        [
            "type": type.rawValue
        ]
    }

    var type: ErrorEventType
}
