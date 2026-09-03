//
//  LibwalletMigrationHelper.swift
//  falcon
//
//  Created by Gonzalo Martone on 12/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation
import CryptoKit

public enum LibwalletMigrationResult {
    case succeeded(sizeMB: Double, sizeIsPartial: Bool, elapsedMs: Int, attempts: Int)
    case failed(attempts: Int)
}

public enum LibwalletMigrationHelper: Resolver {

    private enum DirectorySize {
        case exact(Int64)
        case partial(Int64)
    }

    private static let maxMigrationAttempts = 5
    private static let hashChunkSize = 65_536
    private static let bytesPerMB: Double = 1_048_576
    private static let msPerSecond: Double = 1_000

    // Libwallet directory in the app-group container, shared with the notification service
    // extension.
    static var appGroupLibwalletURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Identifiers.appGroup)?
            .appendingPathComponent("libwallet", isDirectory: true)
    }

    // Path to an empty file in the app-group container whose presence means libwallet data
    // is canonically in the app group - either migrated from Documents or, on a fresh
    // install, established there directly.
    private static var migrationMarkerURL: URL? {
        appGroupLibwalletURL?.appendingPathComponent(".migrated-from-documents")
    }

    // Whether libwallet data lives in the app-group container (migrated from Documents, or
    // established there on a fresh install). Environment uses this to decide which directory
    // libwalletDataDirectory should return.
    static var isMigrated: Bool {
        guard let marker = migrationMarkerURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: marker.path)
    }

    /// Copies libwallet files from the legacy Documents/libwallet path to the app-group
    /// container so the Notification Service Extension can access them.
    /// Safe to call on every launch: no-ops once migrated. On a fresh install (no legacy
    /// data) it marks the app group as canonical so the app uses it from the first launch.
    /// Originals are deleted only after the integrity check passes; on total failure they
    /// are left intact so the app can continue using them.
    public static func migrateFromDocumentsIfNeeded() -> LibwalletMigrationResult? {
        let fileManager = FileManager.default
        let oldDir = Environment.current.legacyDocumentsLibwalletURL

        guard let newDir = Self.appGroupLibwalletURL,
              let marker = migrationMarkerURL else {
            Logger.log(.err, "[LibwalletMigration] group container unavailable, skipping")
            return nil
        }

        if fileManager.fileExists(atPath: marker.path) {
            return nil
        }

        guard fileManager.fileExists(atPath: oldDir.path) else {
            // Fresh install: there is no legacy data to migrate. Write the marker now so the
            // app group is used from the first launch; otherwise we would start in the legacy
            // directory and run a pointless migration on the second launch.
            markAppGroupAsCanonical(newDir: newDir, marker: marker)
            return nil
        }

        let size = directorySize(at: oldDir)
        let memBefore = os_proc_available_memory()
        let overallStart = CFAbsoluteTimeGetCurrent()

        guard let migrationAttemps = copyWithRetry(from: oldDir, to: newDir) else {
            Logger.log(
                .err,
                "[LibwalletMigration] FAILED after "
                + "\(maxMigrationAttempts) attempts - originals preserved"
            )
            return .failed(attempts: maxMigrationAttempts)
        }

        // The marker is the source of truth for `isMigrated`: until it exists the app keeps
        // reading from the legacy directory. A failed write therefore means the migration
        // did not take effect, even though the copy succeeded, so report it as such.
        do {
            try "".write(to: marker, atomically: true, encoding: .utf8)
        } catch {
            Logger.log(.err, "[LibwalletMigration] marker write failed - migration not durable")
            Logger.log(error: error)
            return .failed(attempts: migrationAttemps)
        }

        // Best-effort: the originals are now redundant. If removal fails the marker still
        // signals the app group is ready, so libwalletDataDirectory uses it next launch.
        do {
            try fileManager.removeItem(at: oldDir)
        } catch {
            Logger.log(error: error)
        }

        return finishSucceeded(
            size: size,
            attempt: migrationAttemps,
            memBefore: memBefore,
            overallStart: overallStart
        )
    }

    /// Fresh-install path: marks the app group as the canonical libwallet directory without
    /// copying anything. Best-effort; on failure we use the legacy dir and retry next launch.
    private static func markAppGroupAsCanonical(newDir: URL, marker: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(
                at: newDir,
                withIntermediateDirectories: true,
                attributes: [:]
            )
            try "".write(to: marker, atomically: true, encoding: .utf8)
        } catch {
            Logger.log(.err, "[LibwalletMigration] failed to init app group on fresh install")
            Logger.log(error: error)
        }
    }

    private static func finishSucceeded(
        size: DirectorySize,
        attempt: Int,
        memBefore: Int,
        overallStart: CFAbsoluteTime
    ) -> LibwalletMigrationResult {
        let elapsed = CFAbsoluteTimeGetCurrent() - overallStart
        let memAfter = os_proc_available_memory()
        let sizeBytes: Int64
        let sizeSuffix: String
        let sizeIsPartial: Bool
        switch size {
        case .exact(let b):
            (sizeBytes, sizeSuffix, sizeIsPartial) = (b, "", false)
        case .partial(let b):
            (sizeBytes, sizeSuffix, sizeIsPartial) = (b, " (partial)", true)
        }
        let sizeMB = Double(sizeBytes) / bytesPerMB
        let memDeltaMB = Double(Int64(memBefore) - Int64(memAfter)) / bytesPerMB
        let availableMB = Double(memAfter) / bytesPerMB
        let elapsedMs = Int(elapsed * msPerSecond)
        Logger.log(
            .info,
            "[LibwalletMigration] OK attempt=\(attempt) sizeMB=\(sizeMB)\(sizeSuffix) "
            + "elapsedMs=\(elapsedMs) memDelta=\(memDeltaMB)MB available=\(availableMB)MB"
        )
        return .succeeded(
            sizeMB: sizeMB,
            sizeIsPartial: sizeIsPartial,
            elapsedMs: elapsedMs,
            attempts: attempt
        )
    }

    private static func copyWithRetry(from oldDir: URL, to newDir: URL) -> Int? {
        for attempt in 1...maxMigrationAttempts {
            do {
                if try attemptCopy(from: oldDir, to: newDir, attempt: attempt) {
                    return attempt
                }
            } catch {
                Logger.log(.err, "[LibwalletMigration] error attempt=\(attempt): \(error)")
            }
        }
        return nil
    }

    private static func attemptCopy(from oldDir: URL, to newDir: URL, attempt: Int) throws -> Bool {
        let fileManager = FileManager.default

        // Clean up any partial copy from the previous attempt.
        if fileManager.fileExists(atPath: newDir.path) {
            try fileManager.removeItem(at: newDir)
        }
        try fileManager.createDirectory(
            at: newDir,
            withIntermediateDirectories: true,
            attributes: [:]
        )

        let items = try fileManager.contentsOfDirectory(
            at: oldDir,
            includingPropertiesForKeys: [.isRegularFileKey]
        )

        var sourceHashes: [String: Data] = [:]
        for item in items {
            // We are expecting files only, thus we should fail if directories are present
            // to avoid loosing data.
            let isRegular = try item.resourceValues(forKeys: [.isRegularFileKey])
                .isRegularFile ?? false
            guard isRegular else {
                Logger.log(
                    .err,
                    "[LibwalletMigration] non-regular entry, refusing to migrate: "
                    + "\(item.lastPathComponent) (attempt \(attempt))"
                )
                return false
            }
            sourceHashes[item.lastPathComponent] = Data(try fileHash(at: item))
        }

        for item in items {
            try fileManager.copyItem(
                at: item,
                to: newDir.appendingPathComponent(item.lastPathComponent)
            )
        }

        for item in items {
            let dest = newDir.appendingPathComponent(item.lastPathComponent)
            let copiedHash = Data(try fileHash(at: dest))
            guard copiedHash == sourceHashes[item.lastPathComponent] else {
                Logger.log(
                    .warn,
                    "[LibwalletMigration] hash mismatch: "
                    + "\(item.lastPathComponent) (attempt \(attempt))"
                )
                return false
            }
        }
        return true
    }

    private static func fileHash(at url: URL) throws -> SHA256Digest {
        let handle = try FileHandle(forReadingFrom: url)
        defer { handle.closeFile() }

        var hasher = SHA256()
        while true {
            let chunk = handle.readData(ofLength: hashChunkSize)
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hasher.finalize()
    }

    private static func directorySize(at url: URL) -> DirectorySize {
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: [.fileSizeKey], options: []
            )
        } catch {
            return .partial(0)
        }
        var total: Int64 = 0
        var complete = true
        for file in contents {
            do {
                let values = try file.resourceValues(forKeys: [.fileSizeKey])
                total += Int64(values.fileSize ?? 0)
            } catch {
                complete = false
            }
        }
        return complete ? .exact(total) : .partial(total)
    }
}
