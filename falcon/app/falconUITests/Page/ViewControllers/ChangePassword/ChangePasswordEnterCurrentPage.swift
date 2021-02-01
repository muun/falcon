//
//  ChangePasswordEnterCurrentPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 28/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class ChangePasswordEnterCurrentPage: UIElementPage<UIElements.Pages.ChangePasswordEnterCurrent> {

    private lazy var confirmButton = ButtonViewPage(Root.confirmButton)
    private lazy var forgotPasswordButton = LinkButtonPage(Root.forgotPasswordButton)
    private lazy var textInput = TextInputViewPage(Root.textInput)

    init() {
        super.init(root: Root.root)
    }

    func enter(_ password: String) -> ChangePasswordEnterNewPage {
        textInput.type(text: password)
        confirmButton.mainButtonTap()
        return ChangePasswordEnterNewPage()
    }

    func tapForgotPassword() -> ChangePasswordEnterRecoveryCodePage {
        forgotPasswordButton.mainButtonTap()
        return ChangePasswordEnterRecoveryCodePage()
    }

}
