//
//  SignInPasswordPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SignInPasswordPage: UIElementPage<UIElements.Pages.SignInPasswordPage> {

    private(set) lazy var buttonView = ButtonViewPage(Root.continueView)
    private(set) lazy var textInputView = TextInputViewPage(Root.textInputView)
    private lazy var forgotPasswordButton = LinkButtonPage(Root.forgotPasswordButton)

    init() {
        super.init(root: Root.root)
    }

    private func tapContinueButton() {
        buttonView.mainButtonTap()
    }

    func type(password: String) {
        textInputView.type(text: password)
        tapContinueButton()
    }

    func forgotPassword() -> RecoveryCodePage {
        forgotPasswordButton.mainButtonTap()

        return RecoveryCodePage()
    }

}
