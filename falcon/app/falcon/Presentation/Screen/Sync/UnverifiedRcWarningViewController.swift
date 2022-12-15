//
//  UnverifiedRcWarningViewController.swift
//  Muun
//
//  Created by Lucas Serruya on 07/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import UIKit

class UnverifiedRcWarningViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var buttonView: ButtonView!
    var actionButtonTapped: (() -> Void)?

    init(actionButtonTapped: @escaping (() -> Void)) {
        super.init(nibName: "UnverifiedRcWarningViewController", bundle: nil)
        modalPresentationStyle = .fullScreen
        self.actionButtonTapped = actionButtonTapped
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabels()
        setUpButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsHelper.logScreen("unverified_rc_warning", parameters: nil)
    }

    fileprivate func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.SyncViewController.s5
        buttonView.isEnabled = true
    }

    fileprivate func setUpLabels() {
        titleLabel.text = L10n.SyncViewController.s3
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)

        descriptionLabel.style = .description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = L10n.SyncViewController.s4.attributedForDescription()

        descriptionLabel.textAlignment = .center
    }
}

extension UnverifiedRcWarningViewController: ButtonViewDelegate {
    func button(didPress button: ButtonView) {
        actionButtonTapped?()
    }
}
