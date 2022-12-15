//
//  SettingsUITest.swift
//  falconUITests
//
//  Created by Lucas Serruya on 07/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import XCTest

class SettingsUITests: FalconUITests {
    private var homePage: HomePage!

    func test_switchLightningAsDefaultOnReceive_OnAndOff() {
        homePage = createUser()
        checkOnChainsDefaultOnReceive()
        toggleToLnInSettings()
        checkLightingIsDefaultOnReceive()
        toggleToUnifiedFromLNSettings()
        checkUnifiedDefaultOnReceive()
    }
}

private extension SettingsUITests {
    func toggleToLnInSettings() {
        let lightningNetwork = goToLNSettings()
        let actionSheetPage = lightningNetwork.openDropdownFromBtcOption()
        actionSheetPage.tapOnLnOption()
        back()
    }

    func toggleToUnifiedFromLNSettings() {
        let lightningNetwork = goToLNSettings()
        let actionSheetPage = lightningNetwork.openDropdownFromLnOption()
        actionSheetPage.tapOnUnifiedOption()
        back()
    }

    func goToLNSettings() -> LightningNetworkSettingsPage {
        let settingsPage = homePage.goToSettings()
        return settingsPage.tapLightningNetwork()
    }

    func checkLightingIsDefaultOnReceive() {
        let receivePage = homePage.goToHome().tapReceive()
        XCTAssertTrue(receivePage.isLightningSelected())
        XCTAssertFalse(receivePage.isOnChainSelected())
        back()
    }

    func checkOnChainsDefaultOnReceive() {
        let receivePage = homePage.goToHome().tapReceive()
        XCTAssertTrue(receivePage.isOnChainSelected())
        XCTAssertFalse(receivePage.isLightningSelected())
        back()
    }

    func checkUnifiedDefaultOnReceive() {
        let receivePage = homePage.goToHome().tapReceive()
        XCTAssertTrue(receivePage.getStringInQr().contains("🧪"))
        back()
    }
}
