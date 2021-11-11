//
// Created by Juan Pablo Civile on 04/11/2021.
// Copyright (c) 2021 muun. All rights reserved.
//

import Foundation

enum EmergencyKitFlow {
    case export
    case update(feedback: FeedbackModel)
}

extension EmergencyKitFlow {
    var successFeedback: FeedbackModel {
        switch self {
        case .export:
            return FeedbackInfo.emergencyKit
        case .update(let model):
            return model
        }
    }
}
