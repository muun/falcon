//
//  DateFormatter+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 07/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

}
