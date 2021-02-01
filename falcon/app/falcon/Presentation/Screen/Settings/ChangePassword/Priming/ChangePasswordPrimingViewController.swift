//
//  ChangePasswordPrimingViewController.swift
//  falcon
//
//  Created by Manu Herrera on 27/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ChangePasswordPrimingViewController: MUViewController {

    override var screenLoggingName: String {
        return "password_change_start"
    }

    override func loadView() {
        super.loadView()

        self.view = ChangePasswordPrimingView(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        setUpNavigation()
    }

    fileprivate func setUpNavigation() {
        title = L10n.ChangePasswordPrimingViewController.s1
    }

}

extension ChangePasswordPrimingViewController: ChangePasswordPrimingViewDelegate {

    func continueButtonTap() {
        navigationController!.pushViewController(ChangePasswordEnterCurrentViewController(), animated: true)
    }

}
