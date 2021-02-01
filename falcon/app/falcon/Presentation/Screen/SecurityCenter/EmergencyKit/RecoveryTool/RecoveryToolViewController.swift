//
//  RecoveryToolViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 02/09/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class RecoveryToolViewController: MUViewController {

    @IBOutlet fileprivate weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet fileprivate weak var linkLabel: UILabel!
    @IBOutlet fileprivate weak var extraDescriptionLabel: UILabel!

    override var screenLoggingName: String {
        return "export_keys_recovery_tool"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()
    }

    private func setUpNavigation() {
        title = L10n.RecoveryToolViewController.s1
    }

    private func setUpView() {
        setUpLabels()

        animateView()
    }

    private func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.RecoveryToolViewController.s2
        titleAndDescriptionView.descriptionText = L10n.RecoveryToolViewController.s3.attributedForDescription()

        extraDescriptionLabel.style = .description
        extraDescriptionLabel.attributedText = L10n.RecoveryToolViewController.s4.attributedForDescription()
        extraDescriptionLabel.alpha = 0

        linkLabel.style = .description
        linkLabel.attributedText = L10n.RecoveryToolViewController.s5
            .attributedForDescription()
            .set(underline: "https://github.com/muun/recovery", color: Asset.Colors.muunBlue.color)
        linkLabel.alpha = 0
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate {
            self.extraDescriptionLabel.animate(direction: .topToBottom, duration: .short)
            self.linkLabel.animate(direction: .topToBottom, duration: .short)
        }
    }

    @IBAction func linkTapped(_ sender: Any) {
        let recoveryToolUrl = "https://github.com/muun/recovery"
        let params = ["name": "recovery_tool", "url": recoveryToolUrl]
        logEvent("open_web", parameters: params)
        UIApplication.shared.open(URL(string: recoveryToolUrl)!,
                                  options: [:],
                                  completionHandler: nil)
    }

}

extension RecoveryToolViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.RecoveryTool

    func makeViewTestable() {
        self.makeViewTestable(view, using: .root)
    }

}
