//
//  EmailAlreadyUsedViewController.swift
//  falcon
//
//  Created by Manu Herrera on 28/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class EmailAlreadyUsedViewController: MUViewController {

    private var emailView: EmailAlreadyUsedView!

    override var screenLoggingName: String {
        return "email_already_used"
    }

    override func loadView() {
        super.loadView()

        emailView = EmailAlreadyUsedView(delegate: self)
        self.view = emailView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emailView.animateView()
    }

}

extension EmailAlreadyUsedViewController: EmailAlreadyUsedViewDelegate {
    func descriptionTouched() {
        let nc = UINavigationController(rootViewController: SupportViewController(type: .help))
        navigationController!.present(nc, animated: true)
    }
}
