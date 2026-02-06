//
//  ErrorEvent.swift
//  falcon
//
//  Created by Federico Jordán on 08/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

struct ErrorEvent: AnalyticsEvent {
    enum ErrorEventType: String {
        case lnurlInvalidCode = "lnurl_invalid_code"
        case lnurlInvalidTag = "lnurl_invalid_tag"
        case lnurlUnresponsive = "lnurl_unresponsive"
        case lnurlUnknownError = "lnurl_unknown_error"
        case lnurlExpiredInvoice = "lnurl_expired_invoice"
        case lnurlRequestExpired = "lnurl_request_expired"
        case lnurlNoBalance = "lnurl_no_balance"
        case lnurlNoRoute = "lnurl_no_route"
        case lnurlCountryNotSupported = "lnurl_country_not_supported"
        case lnurlAlreadyUsed = "lnurl_already_used"
        case rcSetupStartConnectionError = "rc_setup_start_connection_error"
        case rcSetupFinishConnectionError = "rc_setup_finish_connection_error"
        case rcStaleError = "rc_stale_error"
        case rcCredentialsDontMatchError = "rc_credentials_dont_match_error"
    }

    var name: String { "e_error" }

    var parameters: [String: Any]? {
        [
            "type": type.rawValue
        ]
    }

    var type: ErrorEventType
}
