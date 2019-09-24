//
//  Logger.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
#if !DEBUG
import Crashlytics
#endif

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

        #if !DEBUG
        switch level {
        case .info, .debug:
            // Don't log info or debug when not debugging
            return
        case .warn, .err:
            break
        }
        #endif

        let log = "\(Date()) \(level.rawValue)[\(MuunError.sourceFileName(filePath: filename))]:"
            +  "\(line) \(funcName) -> \(string)"

        #if DEBUG
        // This variant prints to NSLog
        Swift.print(log)
        #else
        CLSLogv("%@", getVaList([log]))
        #endif
    }

    public static func log(error: Error,
                           filename: StaticString = #file,
                           line: UInt = #line,
                           funcName: StaticString = #function) {

        if let muunError = error as? MuunError {

            Logger.log(error: muunError.kind,
                       stacktrace: muunError.stackSymbols,
                       filename: filename,
                       line: line,
                       funcName: funcName)

        } else {
            #if DEBUG
            log(.err, error.localizedDescription, filename: filename, line: line, funcName: funcName)
            #else
            Crashlytics.sharedInstance().recordError(error)
            #endif
        }
    }

    public static func log(error: Error,
                           stacktrace: [String],
                           filename: StaticString = #file,
                           line: UInt = #line,
                           funcName: StaticString = #function) {

        #if DEBUG
        log(.err, error.localizedDescription, filename: filename, line: line, funcName: funcName)
        for trace in stacktrace {
            log(.err, trace, filename: filename, line: line, funcName: funcName)
        }
        #else
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: [
            "stack_trace": stacktrace.joined(separator: "\n")
            ])
        #endif
    }

    public static func fatal(error: Error,
                             filename: StaticString = #file,
                             line: UInt = #line,
                             funcName: StaticString = #function) -> Never {

        if let muunError = error as? MuunError {

            Logger.log(error: muunError.kind,
                       stacktrace: muunError.stackSymbols,
                       filename: filename,
                       line: line,
                       funcName: funcName)

        } else {
            #if !DEBUG
            Crashlytics.sharedInstance().recordError(error)
            #endif
        }

        fatalError(file: filename, line: line)
    }

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

}
