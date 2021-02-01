//
//  PinPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class PinPage: UIElementPage<UIElements.Pages.PinPage> {

    private(set) lazy var keyboardView = KeyboardViewPage(Root.keyboardView)
    private(set) lazy var hintLabel = label(.hintLabel)
    private(set) lazy var gcmTokenlabel = label(.gcmTokenLabel)

    init() {
        super.init(root: Root.root)
    }

    func tapErase() {
        keyboardView.tapErase()
    }

    func enterPin(_ pin: String) {
        for number in pin {
            keyboardView.tap(number: Int(String(describing: number))!)
        }
    }

    func createPinAndAdvance(_ pin: String) -> HomePage {
        print("GCM TOKEN: \(gcmTokenlabel.label)")

        enterPin(pin)

        // Give the next pin page time to appear
        Thread.sleep(forTimeInterval: 1)
        
        // Repeat the pin
        enterPin(pin)

        let homePage = HomePage()
        // Give it some time for all the initial sync calls
        homePage.wait(30)

        return homePage
    }

}
