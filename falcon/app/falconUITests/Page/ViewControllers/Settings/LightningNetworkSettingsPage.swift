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

    func openDropdownFromBtcOption() -> ReceiveFormatActionSheetPage {
        Page.app.staticTexts[L10n.ReceiveFormatSettingDropdownView.receiveFormatBTCOption].tap()
        return ReceiveFormatActionSheetPage()
    }

    func openDropdownFromLnOption() -> ReceiveFormatActionSheetPage {
        Page.app.staticTexts[L10n.ReceiveFormatSettingDropdownView.receiveFormatLNOption].tap()
        return ReceiveFormatActionSheetPage()
    }
}

final class ReceiveFormatActionSheetPage: UIElementPage<UIElements.Pages.ReceiveFormatActionSheetPage> {
    init() {
        super.init(root: Root.root)
    }

    func tapOnLnOption() {
        Page.app.staticTexts[L10n.ReceiveFormatSettingDropdownView.receiveFormatLNOption].tap()
    }

    func tapOnUnifiedOption() {
        Page.app.staticTexts[L10n.ReceiveFormatSettingDropdownView.receiveFormatUnifiedOption].tap()
    }
}
