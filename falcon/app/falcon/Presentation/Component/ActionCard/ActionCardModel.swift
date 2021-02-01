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
}

enum ActionCard {}
