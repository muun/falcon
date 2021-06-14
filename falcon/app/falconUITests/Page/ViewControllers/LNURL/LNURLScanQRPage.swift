//
//  LNURLScanQRPage.swift
//  falconUITests
//
//  Created by Federico Bond on 14/05/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation

final class LNURLScanQRPage: UIElementPage<UIElements.Pages.LNURLScanQRPage> {

    private lazy var enterManuallyButton = ButtonViewPage(Root.enterManually)
    private lazy var permissionView = CameraPermissionPage(Root.cameraPermissionView)

    init() {
        super.init(root: Root.root)
    }

    func enterManually() -> LNURLManuallyEnterQRPage {
        // We might get pushed automatically, so check
        if enterManuallyButton.exists() {
            enterManuallyButton.mainButtonTap()
        }

        return LNURLManuallyEnterQRPage()
    }

}
