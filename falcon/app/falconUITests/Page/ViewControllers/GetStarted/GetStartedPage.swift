//
//  GetStartedPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class GetStartedPage: UIElementPage<UIElements.Pages.GetStartedPage> {

    private(set) lazy var createWalletButton = ButtonViewPage(Root.createWalletButton)
    private(set) lazy var recoverWalletButton = LinkButtonPage(Root.recoverWalletButton)

    init() {
        super.init(root: Root.root)
    }

    func touchCreateWallet() -> PinPage {
        createWalletButton.mainButtonTap()

        return PinPage()
    }

    func touchRecoverWallet() -> SignInEmailPage {
        recoverWalletButton.mainButtonTap()

        return SignInEmailPage()
    }

}
