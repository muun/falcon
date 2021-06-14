//
//  NewOpErrorPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 29/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

final class NewOpErrorPage: UIElementPage<UIElements.Pages.ErrorPage> {

    private lazy var titleLabel = label(.titleLabel)
    private lazy var descriptionLabel = label(.descriptionLabel)
    private lazy var backToHomeButton = LinkButtonPage(Root.secondaryButton)

    init() {
        super.init(root: Root.root)
    }

    func assert(title: String) {
        XCTAssert(titleLabel.label.contains(title), "Expected: \(title) --- Actual: \(titleLabel.label)")
    }

    func backToHome() -> HomePage {
        backToHomeButton.mainButtonTap()
        return HomePage()
    }

    func assertInsufficientFunds() {
        assert(title: L10n.NewOpError.s9)
    }

    func assertDustError() {
        assert(title: L10n.NewOpError.s10)
    }

}
