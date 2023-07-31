//
//  ActionCardModel.swift
//  falcon
//
//  Created by Manu Herrera on 22/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

struct ActionCardModel {
    let title: NSAttributedString
    let description: NSAttributedString
    let nextViewController: UIViewController?
    let stemNumber: String?
    let stepImage: UIImage?
    let state: ActionCardState
    let accessibilityLabel: String?
    let accessibilityTrait: UIAccessibilityTraits

    init(title: NSAttributedString,
         description: NSAttributedString,
         nextViewController: UIViewController?,
         stemNumber: String?,
         stepImage: UIImage?,
         state: ActionCardState,
         accessibilityLabel: String? = nil,
         accessibilityTrait: UIAccessibilityTraits = .button) {
        self.title = title
        self.description = description
        self.nextViewController = nextViewController
        self.stemNumber = stemNumber
        self.stepImage = stepImage
        self.state = state
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityTrait = accessibilityTrait
    }
}

enum ActionCard {}
