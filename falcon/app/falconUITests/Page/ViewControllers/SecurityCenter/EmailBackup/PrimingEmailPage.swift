//
//  PrimingEmailPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class PrimingEmailPage: UIElementPage<UIElements.Pages.PrimingEmailPage> {

    private lazy var next = ButtonViewPage(Root.next)
    private(set) lazy var skipEmailButton = LinkButtonPage(Root.skipEmail)

    init() {
        super.init(root: Root.root)
    }

    func confirm() -> SetEmailBackUpPage {
        next.mainButtonTap()

        return SetEmailBackUpPage()
    }

    func skipEmail() {
        skipEmailButton.mainButtonTap()
        Page.app.alerts[L10n.EmailPrimingViewController.s3]
            .scrollViews.otherElements.buttons[L10n.EmailPrimingViewController.s6].tap()
        // This action pops the stack to the security center
    }

}
