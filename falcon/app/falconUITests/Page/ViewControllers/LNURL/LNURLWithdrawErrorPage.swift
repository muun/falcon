//
//  LNURLWithdrawErrorPage.swift
//  falconUITests
//
//  Created by Federico Bond on 14/05/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import XCTest

final class LNURLWithdrawErrorPage: UIElementPage<UIElements.Pages.ErrorPage> {

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

    func assertUnknownError() {
        assert(title: L10n.LNURLWithdrawPresenter.unknownErrorTitle)
    }

}
