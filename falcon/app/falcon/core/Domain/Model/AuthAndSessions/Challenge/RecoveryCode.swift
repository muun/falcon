//
//  RecoveryCode.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public struct RecoveryCode {
    static let separator = "-"
    public static let segmentCount = 8
    public static let segmentLength = 4

    public static let alphabet = LibwalletRecoveryCodeAlphabet

    public let segments: [String]
    public let version: Int

    // When calling this method, the RC should already contain the separators
    public init(code: String) throws {
        self.version = try RecoveryCode.validateAndReturnVersion(code)

        let segments = code.split(separator: RecoveryCode.separator.first!).map(String.init)
        self.segments = segments
    }

    public init(segments: [String]) throws {
        let code = segments.joined(separator: RecoveryCode.separator)
        try self.init(code: code)
    }

    public func toKey() throws -> ChallengeKey {
        let key = try doWithError({ error in
            LibwalletRecoveryCodeToKey(self.segments.joined(separator: RecoveryCode.separator), nil, error)
        })

        let type = ChallengeType.RECOVERY_CODE

        return ChallengeKey(
            type: type,
            publicKey: Data(hex: key.pubKeyHex()),
            salt: nil,
            challengeVersion: type.getVersion()
        )
    }

    private static func validateAndReturnVersion(_ code: String) throws -> Int {
        var version: Int = 0
        // For some reason, the binding for this method is mapping to a bool instead of an int, so we need to hack
        // it using the version as a pointer
        _ = try doWithError({ error in
            LibwalletGetRecoveryCodeVersion(code, &version, error)
        })
        return version
    }

    public static func random() -> RecoveryCode {

        let code = LibwalletGenerateRecoveryCode()

        do {
            return try RecoveryCode(code: code)
        } catch {
            // This should never fail since the generation is using the same params
            Logger.fatal(error: error)
        }
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
