//
//  ReceivePage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class ReceivePage: UIElementPage<UIElements.Pages.ReceivePage> {

    private lazy var addressLabel = label(.address)
    private lazy var invoiceLabel = label(.invoice)
    private lazy var enablePushButton = ButtonViewPage(Root.enablePush)
    private lazy var segmentControl = segmentedControl(.segmentedControl)

    // We need a reference to the falcon UI tests class to access the push notification permission interceptor
    private var falconTests = FalconUITests()

    init() {
        super.init(root: Root.root)
    }

    func address() -> String {
        segmentControl.buttons[L10n.ReceiveViewController.s1].tap()

        _ = addressLabel.waitForExistence(timeout: 2)
        if !addressLabel.isHittable {
            enablePushButton.mainButtonTap()
            falconTests.allowNotifications(true)
        }

        return addressLabel.label
    }

    func invoice() -> String {
        segmentControl.buttons[L10n.ReceiveViewController.s2].tap()
        _ = invoiceLabel.waitForExistence(timeout: 2)
        if !invoiceLabel.isHittable {
            enablePushButton.mainButtonTap()
            falconTests.allowNotifications(true)
        }
        return invoiceLabel.label
    }

}
