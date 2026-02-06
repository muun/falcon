//
//  AnalyticsEvent.swift
//  falcon
//
//  Created by Federico Jordán on 05/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

/// Represents a typed analytics event.
/// Each event is responsible for defining:
/// - its event name (`name`)
/// - the parameters it reports, using typed keys
///
/// Example:
///
/// ```
/// struct LoginSucceededEvent: AnalyticsEvent {
///     let title = "login_succeeded"
///     let parameters: [String: Any]? = [
///         "type": "email"
///     ]
/// }
/// ```
protocol AnalyticsEvent {
    var name: String { get }
    /// Note: Parameters are currently typed as `Any` to match Firebase requirements.
    /// This can be restricted in the future if needed.
    var parameters: [String: Any]? { get }
}
