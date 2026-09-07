//
//  Secret.swift
//  Muun
//

import Foundation

/// Wraps plaintext bytes received from libwallet. The buffer is zeroed when
/// `withSecret` returns, whether the callback completes normally or throws,
/// and on `deinit` if the `Secret` is never consumed.
/// Single-use: a second `withSecret` call throws instead of exposing a wiped
/// buffer.
///
/// Never convert the bytes to a `String` inside the callback: Swift `String`s
/// are immutable and cannot be cleared.
final class Secret {
    enum Errors: Error {
        case alreadyConsumed
    }

    private var bytes: Data
    private var consumed = false

    init(_ bytes: Data) {
        self.bytes = bytes
    }
    
    deinit {
        wipe()
    }

    func withSecret(_ fn: (Data) throws -> Void) throws {
        guard !consumed else {
            throw MuunError(Errors.alreadyConsumed)
        }
        consumed = true
        defer { wipe() }
        try fn(bytes)
    }

    /// Overwrites the buffer with zeros. `memset_s` is used instead of
    /// `resetBytes`: a zeroing write to a buffer that is never read again is a
    /// dead store the optimizer is allowed to drop, and `memset_s` is the
    /// variant it must not elide. Apple uses it for key material in
    /// swift-crypto's `SecureBytes`.
    private func wipe() {
        guard !bytes.isEmpty else { return }
        bytes.withUnsafeMutableBytes { _ = memset_s($0.baseAddress, $0.count, 0, $0.count) }
    }
}

extension Secret.Errors: ClassifiedError {
    var classification: ErrorClassification {
        switch self {
        // `alreadyConsumed` only fires on a double consume, which is a logic
        // bug on our side rather than a user or external condition, so it
        // should surface for investigation.
        case .alreadyConsumed:
            return .unexpected
        }
    }
}
