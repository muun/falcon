//
//  SmallButtonViewPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SmallButtonViewPage: UIElementPage<UIElements.CustomViews.SmallButtonViewPage> {

    private(set) lazy var button = self.button(.mainButton)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func mainButtonTap() {
        button.tap()
    }

}
