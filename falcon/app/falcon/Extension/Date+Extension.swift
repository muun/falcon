//
//  Date+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 07/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

extension Date {

    func format(showTime: Bool) -> String {
        let calender = Calendar.current
        let formatter = DateFormatter()

        if calender.isDateInToday(self) {
            // If the opertion is from today we only display the hour: 9:41 AM
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: self)
        }

        if self.isInSameYear(date: Date()) {
            formatter.dateFormat = showTime
                ? "MMM d, h:mm a" // March 18, 9:41 AM
                : "MMM d"         // March 18

            return formatter.string(from: self)
        }

        // If the operation was made in a previous year we display it as: 3/18/95
        formatter.dateStyle = .short
        if showTime {
            formatter.timeStyle = .short // 3/18/95, 9:41 AM
        }
        return formatter.string(from: self)
    }

    func date() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none

        if isInSameYear(date: Date()) {
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: self)
        }

        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    func exportKeysString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        // Convert Houston's UTC time zone to current time zone
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM/dd/yyyy"

        return formatter.string(from: self)
    }

    private func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }

    // This is used to transform the creation date of an user to a Support Identifier
    func getSupportId() -> String {
        // Convert the date to epoch and remove the miliseconds
        let epoch = Int(self.timeIntervalSince1970).description

        // Get the last 8 characters
        var customId = String(epoch.suffix(8))

        // Insert a "-" in the middle to get two 4 characters chunks (1234-5678)
        customId.insert("-", at: customId.index(customId.startIndex, offsetBy: 4))
        return customId
    }

}
