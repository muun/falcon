//
//  SignInEmailPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SignInEmailPage: UIElementPage<UIElements.Pages.SignInEmailPage> {

    private(set) lazy var buttonView = ButtonViewPage(Root.continueView)
    private(set) lazy var textInputView = TextInputViewPage(Root.textInputView)
    private lazy var signInWithRC = LinkButtonPage(Root.signInWithRC)

    init() {
        super.init(root: Root.root)
    }

    private func tapContinueButton() {
        buttonView.mainButtonTap()
    }

    func type(email: String) {
        textInputView.type(text: email)
        tapContinueButton()
    }

    func goToSignInWithRCFlow() -> SignInWithRCPage {
        signInWithRC.mainButtonTap()

        return SignInWithRCPage()
    }

}
