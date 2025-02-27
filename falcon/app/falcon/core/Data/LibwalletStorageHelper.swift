//
//  LibwalletStorageHelper.swift
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation

public enum LibwalletStorageHelper {

    public static func wipe() throws {
        try FileManager.default.removeItem(at: Environment.current.libwalletDataDirectory)
        ensureExists()
    }

    public static func ensureExists() {
        do {
            try FileManager.default.createDirectory(
                at: Environment.current.libwalletDataDirectory,
                withIntermediateDirectories: true,
                attributes: [:]
            )
        } catch {
            Logger.fatal(error: error)
        }
    }

}
