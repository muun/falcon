//
//  PrimingRecoveryCodePage.swift
//  falconUITests
//
//  Created by Manu Herrera on 15/05/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

final class PrimingRecoveryCodePage: UIElementPage<UIElements.Pages.PrimingRecoveryCodePage> {

    private lazy var next = ButtonViewPage(Root.next)

    init() {
        super.init(root: Root.root)
    }

    func confirm() -> GenerateRecoveryCodePage {
        next.mainButtonTap()

        return GenerateRecoveryCodePage()
    }

}
