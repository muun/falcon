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
    let buttonText: String?
    let buttonAction: FeedbackButtonAction?
    let image: UIImage?
    let lottieAnimationName: String?
    let loggingParameters: [String: String]
    // FIXME: delete me once the taproot thing is done cause this is the hackiest hack ever
    let blocksLeft: UInt?

    init(title: String,
         description: NSAttributedString,
         buttonText: String?,
         buttonAction: FeedbackButtonAction?,
         image: UIImage?,
         lottieAnimationName: String?,
         loggingParameters: [String: String],
         blocksLeft: UInt? = nil) {
        self.title = title
        self.description = description
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.image = image
        self.lottieAnimationName = lottieAnimationName
        self.loggingParameters = loggingParameters
        self.blocksLeft = blocksLeft
    }

    static func == (lhs: FeedbackModel, rhs: FeedbackModel) -> Bool {
        return lhs.loggingParameters == rhs.loggingParameters
    }
}

enum FeedbackInfo {}
