//
//  CameraPermissionPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class CameraPermissionPage: UIElementPage<UIElements.CustomViews.CameraPermissionPage> {

    private(set) lazy var button = ButtonViewPage(Root.enable)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func enable() {
        button.mainButtonTap()
    }

}
