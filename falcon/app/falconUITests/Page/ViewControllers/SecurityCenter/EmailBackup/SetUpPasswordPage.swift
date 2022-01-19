//
//  SetUpPasswordPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 11/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SetUpPasswordPage: UIElementPage<UIElements.Pages.SetUpPasswordPage> {

    private(set) lazy var buttonView = ButtonViewPage(Root.continueView)
    private(set) lazy var firstTextInputView = TextInputViewPage(Root.firstTextInputView)
    private(set) lazy var secondTextInputView = TextInputViewPage(Root.secondTextInputView)

    init() {
        super.init(root: Root.root)
    }

    private func tapContinueButton() {
        buttonView.mainButtonTap()
    }

    func type(password: String) {
        firstTextInputView.type(text: password)
        tapContinueButton()
    }

    func repeatPassword(_ password: String) {
        secondTextInputView.type(text: password)
        tapContinueButton()
    }

    func createPassword(_ password: String) -> FinishEmailSetupPage {
        type(password: password)
        repeatPassword(password)
        return FinishEmailSetupPage()
    }

}
