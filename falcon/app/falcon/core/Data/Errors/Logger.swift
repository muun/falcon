//
//  Logger.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

public enum LogLevel: String {
    case err = "[‼️]" // error
    case info = "[ℹ️]" // info
    case debug = "[💬]" // debug
    case warn = "[⚠️]" // warning
}

@available(*, deprecated, message: "you should use the logger")
func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

public class Logger {

    public static func log(_ level: LogLevel,
                           _ string: String,
                           filename: StaticString = #file,
                           line: UInt = #line,
                           funcName: StaticString = #function) {
        logExplicit(level: level,
                    message: string,
                    filename: MuunError.sourceFileName(filePath: filename),
                    line: line,
                    funcName: "\(funcName)")
    }

    public static func logExplicit(level: LogLevel,
                                   message: String,
                                   filename: String,
                                   line: UInt,
                                   funcName: String) {

        #if !DEBUG
        switch level {
        case .info, .debug:
            // Don't log info or debug when not debugging
            return
        case .warn, .err:
            break
        }
        #endif

        let log = "\(Date()) \(level.rawValue)[\(filename)]:\(line) \(funcName) -> \(message)"

        #if DEBUG
        // This variant prints to NSLog
        Swift.print(log)
        #else
        Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([log]))
        #endif
    }

    @inline(never)
    public static func log(error: Error,
                           filename: StaticString = #file,
                           line: UInt = #line,
                           funcName: StaticString = #function) {

        #if DEBUG
        log(.err, error.localizedDescription, filename: filename, line: line, funcName: funcName)
        #else
        reportToCrashlytics(error: error,
                            filename: filename,
                            line: line,
                            funcName: funcName)
        #endif

    }

    @inline(never)
    public static func fatal(error: Error,
                             filename: StaticString = #file,
                             line: UInt = #line,
                             funcName: StaticString = #function) -> Never {

        reportToCrashlytics(error: error,
                            filename: filename,
                            line: line,
                            funcName: funcName)

        fatalError(file: filename, line: line)
    }

    @inline(never)
    public static func fatal(_ string: String,
                             filename: StaticString = #file,
                             line: UInt = #line,
                             funcName: StaticString = #function) -> Never {

        Logger.log(.err,
                   string,
                   filename: filename,
                   line: line,
                   funcName: funcName)

        fatalError(file: filename, line: line)
    }

    @inline(never)
    private static func reportToCrashlytics(error: Error,
                                            filename: StaticString = #file,
                                            line: UInt = #line,
                                            funcName: StaticString = #function) {

        // It is quite important that this method be called in one level of nesting inside the Logger
        // We do a hack of dropping the first 2 lines of the trace to make sure the report caught site is
        // outside the logger.

        if let muunError = error as? MuunError {
            let exception = ExceptionModel(name: String(describing: muunError.kind), reason: muunError.localizedDescription)

            var trace = [StackFrame]()
            trace.append(StackFrame(symbol: "<<<<<<<<<< Caught at >>>>>>>>>>", file: "", line: 0))
            // First two frames are the caller to the logger and this own method
            trace.append(contentsOf: Thread.callStackReturnAddresses.dropFirst(2).map { StackFrame(address: $0.uintValue) })

            trace.append(StackFrame(symbol: "<<<<<<<<<< Original callsite >>>>>>>>>>", file: "", line: 0))
            // First line is the constructor of MuunError
            trace.append(contentsOf: muunError.stacktrace.dropFirst().map { StackFrame(address: $0.uintValue) })

            exception.stackTrace = trace

            Crashlytics.crashlytics().record(exceptionModel: exception)
            Crashlytics.crashlytics().sendUnsentReports()
        } else {
            Crashlytics.crashlytics().record(error: transformError(
                error: error,
                filename: filename,
                line: line,
                funcName: funcName
            ))
        }
    }

    private static func transformError(error: Error,
                                       filename: StaticString = #file,
                                       line: UInt = #line,
                                       funcName: StaticString = #function) -> Error {

        let caller = "\(MuunError.sourceFileName(filePath: filename)) \(line) \(funcName)"
        let additionalInfo: [String: Any] = [
            NSLocalizedDescriptionKey: error.localizedDescription,
            "caught_at": caller
        ]

        let domain = "\(error.localizedDescription) - \(caller)"
        return NSError(domain: domain, code: 0, userInfo: additionalInfo)
    }

}
