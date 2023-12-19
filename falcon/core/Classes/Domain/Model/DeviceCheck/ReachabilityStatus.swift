//
//  DeviceCheckReachability.swift
//  core-all
//
//  Created by Lucas Serruya on 26/10/2023.
//

import Foundation

/// This model allow us to measure what services are reachable at a given moment. It will be collected by ApiReachabilityService.
public struct ReachabilityStatus {
    let houston: Bool
    let deviceCheck: Bool
}
