//
//  DeviceCheckAdapter.swift
//  core-all
//
//  Created by Lucas Serruya on 19/10/2023.
//

import Foundation

public protocol DeviceCheckAdapter {
    func isSupported() -> Bool
    func generateToken(completionHandler completion: @escaping (Data?, Error?) -> Void)
}
