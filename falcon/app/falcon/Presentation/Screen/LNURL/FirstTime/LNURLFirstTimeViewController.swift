//
//  FirstTimeViewController.swift
//  falcon
//
//  Created by Federico Bond on 08/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit


class LNURLFirstTimeViewController: MUViewController {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let continueButton = ButtonView()

    override var screenLoggingName: String {
        return "lnurl_first_time"
    }

    private lazy var presenter = instancePresenter(LNURLFirstTimePresenter.init, delegate: self)

    init() {
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
        titleLabel.text = L10n.LNURLFirstTimeViewController.title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(8, after: titleLabel)

        descriptionLabel.attributedText = L10n.LNURLFirstTimeViewController.description
            .attributedForDescription()
        descriptionLabel.textAlignment = .center
        descriptionLabel.style = .description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(descriptionLabel)

        setUpContinueButton()

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setUpContinueButton() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.delegate = self
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension LNURLFirstTimeViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        presenter.didTapContinue()

        let vc = LNURLScanQRViewController()
        navigationController!.pushViewController(vc, animated: true)
    }

}

extension LNURLFirstTimeViewController: LNURLFirstTimePresenterDelegate {}

extension LNURLFirstTimeViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.LNURLFirstTimePage

    func makeViewTestable() {
        makeViewTestable(self.view, using: .root)
        makeViewTestable(continueButton, using: .continueButton)
    }

}
