//
//  ReachabilityProvider.swift
//  falcon
//
//  Created by Ramiro Repetto on 09/10/2025.
//  Copyright © 2025 muun. All rights reserved.
//

public class ReachabilityProvider {
    var reachabilityService: ReachabilityService?

    func getStatus () -> ReachabilityStatusDTO? {

        var reachabilityStatusDTO: ReachabilityStatusDTO?

        let reachabilityStatus = reachabilityService?.getReachabilityStatus()
        reachabilityStatus.map {
            reachabilityStatusDTO = ReachabilityStatusDTO.from(model: $0)
        }
        return reachabilityStatusDTO
    }
}
