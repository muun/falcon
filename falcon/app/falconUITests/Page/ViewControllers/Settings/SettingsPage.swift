//
//  SettingsPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 21/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SettingsPage: UIElementPage<UIElements.Pages.SettingsPage> {

    init() {
        super.init(root: Root.root)
    }

    func logout() -> GetStartedPage {
        Page.app.staticTexts[L10n.SettingsViewController.s4].tap()
        Page.app.alerts[L10n.SettingsViewController.s15].buttons[L10n.SettingsViewController.s4].tap()
        return GetStartedPage()
    }

    func tapChangePassword() -> ChangePasswordPrimingPage {
        Page.app.staticTexts[L10n.SettingsViewController.s9].tap()
        return ChangePasswordPrimingPage()
    }

    func assertLogoutIsBlocked() {
        Page.app.staticTexts[L10n.SettingsViewController.s4].tap()
        Page.app.alerts[L10n.SettingsViewController.s12].buttons[L10n.SettingsViewController.ok].tap()
    }

    func tapLightningNetwork() -> LightningNetworkSettingsPage {
        Page.app.staticTexts[L10n.SettingsViewController.lightningNetwork].tap()
        return LightningNetworkSettingsPage()
    }
}
