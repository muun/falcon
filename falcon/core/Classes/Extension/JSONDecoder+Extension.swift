//
//  DateFormatter+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 07/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

extension Formatter {

    public static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public static let iso8601noFS = ISO8601DateFormatter()

    fileprivate static let compatDecoder: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        // Use a fixed locale cause otherwise DateFormatter ignores the modifers above and
        // transforms them according to the users settings, breaking date formatting.
        // https://developer.apple.com/library/archive/qa/qa1480/_index.html
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        return dateFormatter
    }()
}

// This is public for the notifications extension
public extension JSONDecoder.DateDecodingStrategy {

    static let customISO8601 = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        if #available(iOS 12, *) {

            if let date = Formatter.iso8601.date(from: string) {
                return date
            }
        } else {

            if let date = Formatter.compatDecoder.date(from: string) {
                return date
            }
        }

        if let date = Formatter.iso8601noFS.date(from: string) {
            return date
        }

        throw MuunError(DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)"))
    }
}

extension JSONEncoder.DateEncodingStrategy {
    public static let customISO8601 = custom { date, encoder throws in
        var container = encoder.singleValueContainer()

        if #available(iOS 12, *) {
            try container.encode(Formatter.iso8601.string(from: date))
        } else {
            try container.encode(Formatter.compatDecoder.string(from: date))
        }
    }
}

extension JSONEncoder {

    public static func data<T: Encodable>(json: T) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .customISO8601

        guard let jsonData = try? encoder.encode(json) else {
            fatalError("Error encoding json: \(json)")
        }
        return jsonData
    }

    static func data<T: APIConvertible> (from model: T) -> Data {
        return data(json: model.toJson())
    }
}

extension JSONDecoder {

    public static func model<T: Decodable>(from data: Data) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601

        return try? decoder.decode(T.self, from: data)
    }
}
