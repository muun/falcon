//
//  SetEmailBackUpPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 11/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SetEmailBackUpPage: UIElementPage<UIElements.Pages.SetEmailBackUpPage> {

    private(set) lazy var buttonView = ButtonViewPage(Root.continueView)
    private(set) lazy var textInputView = TextInputViewPage(Root.textInputView)

    init() {
        super.init(root: Root.root)
    }

    private func tapContinueButton() {
        buttonView.mainButtonTap()
    }

    func type(email: String, shouldTapContinue: Bool = true) {
        textInputView.type(text: email)
        if shouldTapContinue {
            tapContinueButton()
        }
    }

}
