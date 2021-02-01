//
//  NewOpErrorPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 29/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import XCTest

final class NewOpErrorPage: UIElementPage<UIElements.Pages.NewOp.ErrorView> {

    private lazy var titleLabel = label(.titleLabel)
    private lazy var descriptionLabel = label(.descriptionLabel)
    private lazy var backToHomeButton = LinkButtonPage(Root.button)

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
        assert(title: L10n.NewOpErrorView.s9)
    }

    func assertDustError() {
        assert(title: L10n.NewOpErrorView.s10)
    }

}
