//
//  DebugRequestsRepository.swift
//  core-all
//
//  Created by Lucas Serruya on 20/09/2023.
//

import Foundation

// This repository store request ON DEBUG only
public class DebugRequestsRepository {
    var storedRequests = [DebugRequest]()

    public func save(request: BaseRequest,
                     response: URLResponse?,
                     data: Data?,
                     error: Error?) {
        #if DEBUG
        let debugRequest = DebugRequest(request: request,
                                        response: response,
                                        data: data,
                                        error: error)
        storedRequests.append(debugRequest)
        #endif
    }

    public func getAll() -> [DebugRequest] {
        #if DEBUG
        storedRequests
        #else
        return []
        #endif
    }
}
