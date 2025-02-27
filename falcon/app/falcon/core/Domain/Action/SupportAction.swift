//
//  SupportAction.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public class SupportAction: AsyncAction<()> {

    public enum RequestType: String {
        case feedback
        case help
        case support
        case cloudRequest
    }

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "SupportAction")
    }

    public func run(type: RequestType, text: String) {
        let feedback: String
        let jsonType: FeedbackTypeJson
        switch type {
        case .feedback:
            feedback = "--- On general \(type) ---\n\n\(text)"
            jsonType = .support
        case .help:
            feedback = "--- On general \(type) ---\n\n\(text)"
            jsonType = .support
        case .support:
            feedback = "--- On general \(type) ---\n\n\(text)"
            jsonType = .support
        case .cloudRequest:
            jsonType = .cloudRequest
            feedback = text
        }

        runSingle(houstonService.submitFeedback(feedback: feedback, type: jsonType))
    }

}
