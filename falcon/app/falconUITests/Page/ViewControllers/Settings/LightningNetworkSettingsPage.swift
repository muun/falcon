//
//  LightningNetworkSettingsPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class LightningNetworkSettingsPage: UIElementPage<UIElements.Pages.LightningNetworkSettingsPage> {

    private lazy var turboChannels = switchControl(.turboChannels)

    init() {
        super.init(root: Root.root)
    }

    func tapTurboChannels() {
        turboChannels.tap()
    }

}
