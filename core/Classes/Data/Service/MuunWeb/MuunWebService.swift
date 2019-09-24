//
//  MuunWebService.swift
//  falcon
//
//  Created by Manu Herrera on 25/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import RxSwift

public class MuunWebService: BaseService {

    init(preferences: Preferences, urlSession: URLSession, sessionRepository: SessionRepository) {
        super.init(preferences: preferences,
                   urlSession: urlSession,
                   sessionRepository: sessionRepository,
                   sendAuth: false)
    }

    override public func getBaseURL() -> String {
        return Environment.current.muunWebURL
    }

    func fetchLappList() -> Single<[Lapp]> {
        return get("lappList.json", andReturn: [LappJson].self)
            .map({ $0.toModel() })
    }

}
