//
//  ManuallyEnterPage.swift
//  falconUITests
//
//  Created by Juan Pablo Civile on 25/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class ManuallyEnterQRPage: UIElementPage<UIElements.Pages.ManuallyEnterQRPage> {

    private lazy var input = LargeTextInputViewPage(Root.input)
    private lazy var submitButton = ButtonViewPage(Root.submit)

    init() {
        super.init(root: Root.root)
    }

    func send(to address: String) -> NewOperationPage {
        input.type(text: address)
        submitButton.mainButtonTap()

        return NewOperationPage()
    }

}
