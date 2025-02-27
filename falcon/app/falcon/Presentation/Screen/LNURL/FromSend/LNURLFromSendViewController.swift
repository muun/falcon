//
//  LNURLFromSendViewController.swift
//  falcon
//
//  Created by Federico Bond on 20/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit


class LNURLFromSendViewController: MUViewController {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let backButton = LinkButtonView()
    private let continueButton = ButtonView()

    override var screenLoggingName: String {
        return "lnurl_from_send"
    }

    private let qr: String

    init(qr: String) {
        self.qr = qr
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        setUpView()

        makeViewTestable()
    }

    private func setUpView() {
        view = UIView()

        setUpStackView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigation()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(true, animated: true)
    }

    private func setUpStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        imageView.image = Asset.Assets.qrLnurl.image
        imageView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(imageView)
        stackView.setCustomSpacing(24, after: imageView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 140),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)
        ])

        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.textAlignment = .center
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.text = L10n.LNURLFromSendViewController.title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(8, after: titleLabel)

        descriptionLabel.attributedText = L10n.LNURLFromSendViewController.description
            .attributedForDescription()
        descriptionLabel.textAlignment = .center
        descriptionLabel.style = .description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(descriptionLabel)

        setUpContinueButton()
        setUpBackButton()

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setUpContinueButton() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.delegate = self
        continueButton.buttonText = L10n.LNURLFromSendViewController.receiveBitcoin
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.delegate = self
        backButton.buttonText = L10n.LNURLFromSendViewController.goBack
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backButton.bottomAnchor.constraint(equalTo: continueButton.topAnchor)
        ])
    }

    func makeViewTestable() {

    }
}

extension LNURLFromSendViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        let vc = LNURLWithdrawViewController(qr: qr)
        navigationController!.pushViewController(vc, animated: true)
    }

}

extension LNURLFromSendViewController: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        navigationController!.popViewController(animated: true)
    }

}
