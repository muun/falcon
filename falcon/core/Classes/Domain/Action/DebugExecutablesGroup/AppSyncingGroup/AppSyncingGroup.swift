//
//  AppSyncingGroup.swift
//  Muun
//
//  Created by Lucas Serruya on 23/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

class AppSyncingGroup: BaseDebugExecutablesGroup {
    init(realTimeData: RealTimeDataAction) {
        let syncRealTimeData = SyncRealtimeDataDebugExecutable(realTimeDataAction: realTimeData)
        let showRequests = ShowRequestsDebugExecutable()
        super.init(category: "App syncing",
                   executables: [syncRealTimeData,
                                showRequests])
    }
}
