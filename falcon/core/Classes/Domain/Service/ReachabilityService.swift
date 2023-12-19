//
//  DeviceCheckReachabiltiyService.swift
//  core-all
//
//  Created by Lucas Serruya on 23/10/2023.
//

import Foundation

public protocol ReachabilityService {
    func collectReachabilityStatusIfNeeded()
    func getReachabilityStatus() -> ReachabilityStatus?
}
