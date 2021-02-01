//
//  UpdateAppViewController.swift
//  falcon
//
//  Created by Manu Herrera on 01/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class UpdateAppViewController: MUViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var buttonView: ButtonView!

    override var screenLoggingName: String {
        return "update_app"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.setNavigationBarHidden(true, animated: true)
    }

    private func setUpView() {
        setUpLabels()
        setUpButton()

        animateView()
    }

    private func setUpLabels() {
        titleLabel.text = L10n.UpdateAppViewController.s1
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2)
        titleLabel.alpha = 0

        descriptionLabel.text =
            L10n.UpdateAppViewController.s2
        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        descriptionLabel.font = Constant.Fonts.description
        descriptionLabel.alpha = 0
    }

    private func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.UpdateAppViewController.s3
        buttonView.isEnabled = true
        buttonView.alpha = 0
    }

    fileprivate func animateView() {
        titleLabel.animate(direction: .topToBottom, duration: .short) {
            self.descriptionLabel.animate(direction: .topToBottom, duration: .short)
        }

        buttonView.animate(direction: .bottomToTop, duration: .short, delay: .short3)
    }

}

extension UpdateAppViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        UIApplication.shared.open(URL(string: Constant.MuunURL.appStoreLink)!)
    }

}
