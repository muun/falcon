//
//  LinkButtonPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class LinkButtonPage: UIElementPage<UIElements.CustomViews.LinkButtonPage> {

    private(set) lazy var button = self.button(.mainButton)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func mainButtonTap() {
        button.tap()
    }

}
