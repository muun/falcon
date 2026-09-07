//
//  NewOpActionEvent.swift
//  falcon
//
//  Created by Daniel Mankowski on 08/02/2026.
//  Copyright © 2026 muun. All rights reserved.
//

struct NewOpActionEvent: AnalyticsEvent {
    enum `Type`: String {
        case disableFlag = "disable_flag"
        case cancelDisableFlag = "cancel_disable_flag"
        case disableFlagDialogShown = "disable_flag_dialog_shown"
        case abort = "abort"
        case cancelAbort = "cancel_abort"
        case securityCardRetry = "security_card_retry"
    }

    var parameters: [String: AnalyticsValue]? {
        var params: [String: AnalyticsValue] = ["type": type.rawValue]
        if let has2fa {
            params["has_2fa"] = has2fa
        }
        return params
    }

    let name: String = "e_new_op_action"
    let type: `Type`
    let has2fa: Bool?

    init(type: `Type`, has2fa: Bool? = nil) {
        self.type = type
        self.has2fa = has2fa
    }
}
