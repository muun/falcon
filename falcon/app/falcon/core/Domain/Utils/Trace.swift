//
//  Trace.swift
//  falcon
//
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

/// A running timing measurement. Call finish to report the elapsed time.
final class Trace {

    private let label: String
    // We use CLOCK_MONOTONIC_RAW (via clock_gettime_nsec_np) instead of Date() or DispatchTime for
    // two reasons:
    //   1. Unlike Date(), it is monotonic: unaffected by NTP (Network Time Protocol) adjustments
    //      or the user manually changing the device clock mid-measurement.
    //   2. Unlike DispatchTime.uptimeNanoseconds, it does NOT pause when the device is suspended
    //      (e.g. screen off, app backgrounded), so elapsed time is always wall-accurate.
    private let startTime: UInt64
    private var finished = false
    private var children: [ChildTrace] = []
    private var manualChildren: [(String, String)] = []

    init(label: String) {
        self.label = label
        self.startTime = clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
    }

    /// Create a child trace. Call ChildTrace.finish when the child operation completes.
    func child(_ label: String) -> ChildTrace {
        let child = ChildTrace(label: label)
        children.append(child)
        return child
    }

    /// Attach a child whose value was measured elsewhere (e.g. inside libwallet and returned over
    /// gRPC), rather than timed by this Trace.
    func addChild(_ label: String, value: Int64) {
        manualChildren.append((label, String(value)))
    }

    /// Report the elapsed time to analytics.
    func finish() {
        guard !finished else {
            let log = "[TIMING] \(label) finished more than once"
            Logger.log(error: NSError(domain: log, code: 1))
            assertionFailure(log)
            return
        }
        finished = true
        let elapsedMs = (clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW) - startTime) / 1_000_000
        let childMap = Dictionary(
            children.map { $0.result() } + manualChildren,
            uniquingKeysWith: { _, latest in latest }
        )
        AnalyticsHelper.logEvent(
            TimeTrackerEvent(
                label: label,
                elapsedMs: Int(elapsedMs),
                children: childMap
            )
        )
    }

    /// Execute block and report elapsed time when it returns, even if it throws.
    @discardableResult
    func toMeasure<T>(_ block: () throws -> T) rethrows -> T {
        defer { finish() }
        return try block()
    }
}
