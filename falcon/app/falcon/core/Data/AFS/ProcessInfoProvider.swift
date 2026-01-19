//
//  ProcessInfoProvider.swift
//  falcon
//
//  Created by Ramiro Repetto on 08/10/2025.
//  Copyright © 2025 muun. All rights reserved.
//
import Foundation

public class ProcessInfoProvider {

    func getOsVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
}
