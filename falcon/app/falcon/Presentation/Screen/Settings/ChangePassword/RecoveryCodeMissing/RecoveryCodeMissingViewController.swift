//
//  RecoveryCodeMissingViewController.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class RecoveryCodeMissingViewController: MUViewController {

    override var screenLoggingName: String {
        return "recovery_code_missing"
    }

    override func loadView() {
        super.loadView()

        self.view = RecoveryCodeMissingView(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        setUpNavigation()
    }

    fileprivate func setUpNavigation() {
        title = ""
    }

}

extension RecoveryCodeMissingViewController: RecoveryCodeMissingViewDelegate {

    func continueButtonTap() {
        navigationController!.pushViewController(
            SecurityCenterViewController(origin: .bannerSetupEmail),
            animated: true
        )
    }

}
