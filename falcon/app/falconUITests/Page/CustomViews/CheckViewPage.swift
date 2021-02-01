//
//  CheckViewPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 12/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class CheckViewPage: UIElementPage<UIElements.CustomViews.CheckViewPage> {

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func tap() {
        element.tap()
    }
}
