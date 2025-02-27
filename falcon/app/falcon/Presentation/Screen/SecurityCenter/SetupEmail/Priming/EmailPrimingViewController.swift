//
//  EmailPrimingViewController.swift
//  falcon
//
//  Created by Manu Herrera on 21/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class EmailPrimingViewController: MUViewController {

    @IBOutlet fileprivate weak var stackView: UIStackView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var button: ButtonView!
    @IBOutlet fileprivate weak var skipEmailButton: LinkButtonView!

    fileprivate lazy var presenter = instancePresenter(EmailPrimingPresenter.init, delegate: self)

    private var wording: SetUpEmailWording

    override var screenLoggingName: String {
        return "email_priming"
    }

    init(wording: SetUpEmailWording) {
        self.wording = wording

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()
    }

    private func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = ""
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpButton()
        setUpSkipEmailButton()

        makeViewTestable()

        animateView()
    }

    fileprivate func setUpLabels() {
        titleLabel.alpha = 0
        descriptionLabel.alpha = 0

        titleLabel.style = .title
        titleLabel.text = wording.primingTitle()

        descriptionLabel.style = .description
        descriptionLabel.attributedText = wording.primingDescription()
            .attributedForDescription(alignment: .center)

        stackView.setCustomSpacing(12, after: titleLabel)
    }

    fileprivate func animateView() {
        titleLabel.animate(direction: .topToBottom, duration: .short)
        descriptionLabel.animate(direction: .topToBottom, duration: .short)

        button.animate(direction: .bottomToTop, duration: .medium, delay: .short)

        if !presenter.isEmailSkipped() {
            skipEmailButton.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
        }
    }

    fileprivate func setUpButton() {
        button.delegate = self
        button.buttonText = L10n.EmailPrimingViewController.s1
        button.isEnabled = true
        button.alpha = 0
    }

    fileprivate func setUpSkipEmailButton() {
        skipEmailButton.delegate = self
        skipEmailButton.buttonText = L10n.EmailPrimingViewController.s2
        skipEmailButton.isEnabled = true
        skipEmailButton.alpha = 0
    }

}

extension EmailPrimingViewController: LinkButtonViewDelegate {
    func linkButton(didPress linkButton: LinkButtonView) {
        presentSkipEmailAlert()
    }

    private func presentSkipEmailAlert() {
        let title = L10n.EmailPrimingViewController.s3
        let msg = L10n.EmailPrimingViewController.s4
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.EmailPrimingViewController.s5,
                                      style: .destructive,
                                      handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.EmailPrimingViewController.s6,
                                      style: .default,
                                      handler: { _ in
            self.logEvent("email_setup_skipped")
            self.presenter.skipEmail()
            self.navigationController!.popTo(type: SecurityCenterViewController.self)
        }))

        alert.view.tintColor = Asset.Colors.muunBlue.color

        self.present(alert, animated: true)
    }

}

extension EmailPrimingViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        navigationController?.pushViewController(SignUpEmailViewController(wording: wording), animated: true)
    }

}

extension EmailPrimingViewController: EmailPrimingPresenterDelegate {}

extension EmailPrimingViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.PrimingEmailPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(button, using: .next)
        makeViewTestable(skipEmailButton, using: .skipEmail)
    }

}
