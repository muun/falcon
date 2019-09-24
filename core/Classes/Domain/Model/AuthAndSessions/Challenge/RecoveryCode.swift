//
//  RecoveryCode.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct RecoveryCode {
    static let separator = "-"
    public static let segmentCount = 8
    public static let segmentLength = 4
    static let alphabet = [ // Upper-case characters except for numbers/letters that look alike:
        "A", "B", "C", "D", "E", "F", "H", "J", "K", "M", "N", "P", "Q", "R", "S",
        "T", "U", "V", "W", "X", "Y", "Z",
        "2", "3", "4", "5", "7", "8", "9"]

    public let segments: [String]

    public init(segments: [String]) throws {

        guard segments.count == RecoveryCode.segmentCount else {
            throw MuunError(Errors.segmentCount)
        }

        for segment in segments {
            guard segment.count == RecoveryCode.segmentLength  else {
                throw MuunError(Errors.segmentLength)
            }

            for char in segment {
                guard RecoveryCode.isValid(character: char)  else {
                    throw MuunError(Errors.invalidCharacters)
                }
            }
        }

        self.segments = segments
    }

    init(code: String) throws {
        let segments = code.split(separator: RecoveryCode.separator.first!).map(String.init)

        try self.init(segments: segments)
    }

    public func randomSegmentIndexes(count: Int) -> [Int] {

        return segments.enumerated()
            .shuffled()
            .prefix(count)
            .map({ (offset, _) in
                offset
            })

    }

    public static func random() -> RecoveryCode {

        // In iOS 10+ this generator uses /dev/urandom and is considered crypto safe
        var rng = SystemRandomNumberGenerator()

        var segments: [String] = []
        for _ in 0..<segmentCount {

            var segment = ""
            for _ in 0..<segmentLength {
                let index = rng.next(upperBound: UInt(alphabet.count))
                segment += alphabet[Int(index)]
            }

            segments.append(segment)
        }

        do {
            return try RecoveryCode(segments: segments)
        } catch {
            // This should never fail since the generation is using the same params
            Logger.fatal(error: error)
        }
    }

    public static func isValid(character: Character) -> Bool {
        return RecoveryCode.alphabet.contains(String(character))
    }

    enum Errors: Error {
        case segmentCount
        case segmentLength
        case invalidCharacters
    }

}

extension RecoveryCode: CustomStringConvertible {

    public var description: String {
        return segments.joined(separator: RecoveryCode.separator)
    }

}

extension RecoveryCode: Equatable {

    public static func == (lhs: RecoveryCode, rhs: RecoveryCode) -> Bool {
        return lhs.segments == rhs.segments
    }

}
