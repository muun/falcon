//
//  SecurityCardTapEvent.swift
//  falcon
//
//  Created by Federico Jordán on 05/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

struct SecurityCardTapEvent: AnalyticsEvent {

    enum SecurityCardTapEventType: String {
        case tagReaderAlertShown = "tag_reader_alert_shown"
        case tagReaderSessionTimeout = "tag_reader_session_timeout"
        case detected = "detected"
    }

    var name: String { "e_security_card_tap" }

    var parameters: [String: Any]? {
        [
            "type": type.rawValue
        ]
    }

    var type: SecurityCardTapEventType
}
