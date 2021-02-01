//
//  FeedbackPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 26/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class FeedbackPage: UIElementPage<UIElements.Pages.FeedbackPage> {

    private lazy var finishButton = ButtonViewPage(Root.finishButton)

    init() {
        super.init(root: Root.root)
    }

    func finish() {
        finishButton.wait()
        finishButton.mainButtonTap()
    }

}
