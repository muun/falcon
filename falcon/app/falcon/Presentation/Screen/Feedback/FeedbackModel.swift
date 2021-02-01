//
//  FeedbackModel.swift
//  falcon
//
//  Created by Manu Herrera on 23/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

enum FeedbackButtonAction {
    case popToRoot
    case popTo(vc: MUViewController.Type)
    case dismiss
    case setViewControllers(vcs: [UIViewController])
    case resetToGetStarted
}

struct FeedbackModel {
    let title: String
    let description: NSAttributedString
    let buttonText: String
    let buttonAction: FeedbackButtonAction
    let image: UIImage?
    let lottieAnimationName: String?
    let loggingParameters: [String: String]

    static func == (lhs: FeedbackModel, rhs: FeedbackModel) -> Bool {
        return lhs.loggingParameters == rhs.loggingParameters
    }
}

enum FeedbackInfo {}
