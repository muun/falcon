//
//  NotificationReportJSON.swift
//  falcon
//
//  Created by Juan Pablo Civile on 24/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public struct NotificationReportJson: Decodable {

    public let message: Container

    public struct Container: Decodable {
        let previousId: Int
        public let maximumId: Int
        public let preview: [NotificationJson]
    }
}
