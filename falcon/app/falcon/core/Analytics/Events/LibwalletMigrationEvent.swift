//
//  LibwalletMigrationEvent.swift
//  falcon
//
//  Created by Gonzalo A. Martone on 18/05/2026.
//  Copyright © 2026 muun. All rights reserved.
//

struct LibwalletMigrationEvent: AnalyticsEvent {

    let result: LibwalletMigrationResult

    var name: String { "e_libwallet_migration" }

    var parameters: [String: AnalyticsValue]? {
        switch result {
        case .succeeded(let sizeMB, let sizeIsPartial, let elapsedMs, let attempts):
            return [
                "status": "success",
                "size_mb": Int(sizeMB),
                "size_is_partial": sizeIsPartial,
                "elapsed_ms": elapsedMs,
                "attempts": attempts
            ]
        case .failed(let attempts):
            return [
                "status": "failure",
                "attempts": attempts
            ]
        }
    }
}
