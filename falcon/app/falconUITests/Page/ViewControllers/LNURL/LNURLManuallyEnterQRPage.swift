//
//  LNURLManuallyEnterQRPage.swift
//  falconUITests
//
//  Created by Federico Bond on 11/05/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation

final class LNURLManuallyEnterQRPage: UIElementPage<UIElements.Pages.LNURLManuallyEnterQRPage> {

    lazy var input = LargeTextInputViewPage(Root.input)
    lazy var submitButton = ButtonViewPage(Root.submit)

    init() {
        super.init(root: Root.root)
    }

    func enterQR(_ qr: String) {
        input.type(text: qr)
        submitButton.mainButtonTap()
    }
    
}
