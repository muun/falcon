//
//  DateFormatter+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 07/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

// This is public for the notifications extension
public extension JSONDecoder.DateDecodingStrategy {

    static let customISO8601 = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date =
            Formatter.iso8601.date(from: string)
            ??
            Formatter.iso8601noFS.date(from: string)
        {
            return date
        }

        fatalError()
    }
}

extension Formatter {

    public static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public static let iso8601noFS = ISO8601DateFormatter()

}
