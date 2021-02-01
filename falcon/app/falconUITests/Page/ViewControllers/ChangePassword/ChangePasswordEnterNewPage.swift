//
//  ChangePasswordEnterNewPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 04/08/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class ChangePasswordEnterNewPage: UIElementPage<UIElements.Pages.ChangePasswordEnterNew> {

    private lazy var confirmButton = ButtonViewPage(Root.confirmButton)
    private lazy var firstTextInput = TextInputViewPage(Root.firstTextInput)
    private lazy var secondTextInput = TextInputViewPage(Root.secondTextInput)

    init() {
        super.init(root: Root.root)
    }

    func enterNew(_ password: String) -> FeedbackPage {
        firstTextInput.type(text: password)
        confirmButton.mainButtonTap()
        secondTextInput.type(text: password)
        confirmButton.mainButtonTap()
        return FeedbackPage()
    }

}
