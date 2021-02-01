//
//  ScanQRPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class ScanQRPage: UIElementPage<UIElements.Pages.ScanQRPage> {

    private lazy var enterManuallyButton = ButtonViewPage(Root.enterManually)
    private lazy var permissionView = CameraPermissionPage(Root.cameraPermissionView)

    init() {
        super.init(root: Root.root)
    }

    func enterManually() -> ManuallyEnterQRPage {
        // We might get pushed automatically, so check
        if enterManuallyButton.exists() {
            enterManuallyButton.mainButtonTap()
        }

        return ManuallyEnterQRPage()
    }

}
