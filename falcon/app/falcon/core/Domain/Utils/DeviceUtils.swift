//
//  DeviceUtils.swift
//  Created by Juan Pablo Civile on 25/09/2020.
//

import Foundation

import UIKit

public enum DeviceUtils {

    struct Info {
        let model: String
        let osVersion: String
        let appStatus: String
    }

    public static var appState: UIApplication.State = .inactive

    static func deviceInfo() -> Info {
        let device = UIDevice.current
        let appStatus: String

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let modelName = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch appState {
        case .active:
            appStatus = "active"
        case .background:
            appStatus = "background"
        case .inactive:
            appStatus = "inactive"
        default:
            appStatus = "unknown"
        }

        return Info(
            model: modelName,
            osVersion: device.systemVersion,
            appStatus: appStatus
        )
    }

}
