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
    }

    private let houstonService: HoustonService

    public init(houstonService: HoustonService) {
        self.houstonService = houstonService

        super.init(name: "SupportAction")
    }

    public func run(type: RequestType, text: String) {
        let feedback = "--- On general \(type) ---\n\n\(text)"
        runSingle(houstonService.submitFeedback(feedback: feedback))
    }

}
