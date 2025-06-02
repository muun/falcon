import Foundation
import Libwallet

class LibwalletLogHelper: NSObject, App_provided_dataAppLogSinkProtocol {

    func write(_ msgData: Data?, n: UnsafeMutablePointer<Int>?) throws {
        n?.pointee = msgData?.count ?? 0
        guard let msg = msgData else {
            return
        }
        // swiftlint:disable force_error_handling
        let json = try? JSONSerialization.jsonObject(with: msg, options: []) as? [String: Any]

        let level = logLevel(fromGo: json?["level"] as? String)
        let message = json?["msg"] as? String
        let source = json?["source"] as? [String: Any]

        let filename = source?["file"] as? String
        let line = source?["line"] as? UInt
        let function = source?["function"] as? String

        let extraData = extractExtraData(from: json)

        Logger.logExplicit(level: level,
                           message: format(message: message, extras: extraData),
                           filename: filename ?? "<libwallet>",
                           line: line ?? 0,
                           funcName: function ?? "<unknown>")
    }

    private func logLevel(fromGo level: String?) -> LogLevel {
        if level == "DEBUG" {
            return LogLevel.debug
        } else if level == "INFO" {
            return LogLevel.info
        } else if level == "WARN" {
            return LogLevel.warn
        } else {
            // When in doubt, call it an error.
            return LogLevel.err
        }
    }

    private func extractExtraData(from json: [String: Any]?) -> String? {
        // Return all of the non-default top level attributes from the json log as a string.
        let knownKeys: Set = ["time", "level", "msg", "source"]

        return json?
            .filter({ (key: String, _: Any) in
                return !knownKeys.contains(key)
            })
            .map({ (key: String, value: Any) in
                return "\(key)=\(value)"
            })
            .joined(separator: ", ")
    }

    private func format(message: String?, extras: String?) -> String {
        let baseMessage = message ?? "[MISSING MESSAGE]"
        guard let extras = extras, !extras.isEmpty else {
            return baseMessage
        }

        return "\(baseMessage) \(extras)"
    }
}
