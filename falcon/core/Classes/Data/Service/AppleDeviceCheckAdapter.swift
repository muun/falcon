//
//  AppleDeviceCheckAdapter.swift
//  core-all
//
//  Created by Lucas Serruya on 19/10/2023.
//

import DeviceCheck

class AppleDeviceCheckAdapter: DeviceCheckAdapter {
    func isSupported() -> Bool {
        return DCDevice.current.isSupported
    }

    func generateToken(completionHandler completion: @escaping (Data?, Error?) -> Void) {
        DCDevice.current.generateToken(completionHandler: completion)
    }
}

