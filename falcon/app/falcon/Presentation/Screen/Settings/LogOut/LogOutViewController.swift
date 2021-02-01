//
//  LogOutViewController.swift
//  falcon
//
//  Created by Manu Herrera on 21/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

class LogOutViewController: MUViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var buttonView: ButtonView!

    override var screenLoggingName: String {
        return "log_out"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()

        makeViewTestable()
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
        titleLabel.text = L10n.LogOutViewController.s1
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2)
        titleLabel.alpha = 0

        descriptionLabel.text = L10n.LogOutViewController.s3
        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        descriptionLabel.font = Constant.Fonts.description
        descriptionLabel.alpha = 0
    }

    private func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.LogOutViewController.s2
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

extension LogOutViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        resetWindowToGetStarted()
    }

}

extension LogOutViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.LogOutPage

    func makeViewTestable() {
        self.makeViewTestable(self.view, using: .root)
        self.makeViewTestable(self.buttonView, using: .continueButton)
    }

}
