//
//  VerifyEmergencyKitView.swift
//  falcon
//
//  Created by Manu Herrera on 11/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol VerifyEmergencyKitViewDelegate: AnyObject {
    func didTapOnOpenLink()
    func didTapOnContinue()
}

final class VerifyEmergencyKitView: UIView {

    private var contentStackView: UIStackView! = UIStackView()
    private var buttonsStackView: UIStackView! = UIStackView()
    private var continueButton: ButtonView! = ButtonView()
    private var openLinkButton: LinkButtonView! = LinkButtonView()

    private weak var delegate: VerifyEmergencyKitViewDelegate?
    private let option: EmergencyKitSavingOption
    private let hasLink: Bool

    init(delegate: VerifyEmergencyKitViewDelegate?, option: EmergencyKitSavingOption, hasLink: Bool) {
        self.delegate = delegate
        self.option = option
        self.hasLink = hasLink
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpButtonsStackView()
        setUpContentStackView()
    }

    private func setUpButtonsStackView() {
        buttonsStackView.axis = .vertical
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.spacing = 0
        addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])

        setUpButtons()
    }

    private func setUpButtons() {
        openLinkButton.translatesAutoresizingMaskIntoConstraints = false
        openLinkButton.isEnabled = hasLink
        openLinkButton.delegate = self
        openLinkButton.buttonText = option.openInCloudButtonText()
        buttonsStackView.addArrangedSubview(openLinkButton)

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.isEnabled = !hasLink
        continueButton.delegate = self
        continueButton.buttonText = L10n.VerifyEmergencyKitView.done
        buttonsStackView.addArrangedSubview(continueButton)

        NSLayoutConstraint.activate([
            openLinkButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor),
            continueButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor)
        ])
    }

    private func setUpContentStackView() {
        let contentContainerView = UIView()
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.backgroundColor = .clear
        addSubview(contentContainerView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.spacing = 16
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentContainerView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            contentContainerView.topAnchor.constraint(equalTo: topAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),

            contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: contentContainerView.centerYAnchor)
        ])

        setUpImage()
        setUpLabels()
    }

    private func setUpImage() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = option.verifyImage()
        imageView.contentMode = .scaleAspectFit
        contentStackView.addArrangedSubview(imageView)
    }

    private func setUpLabels() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.style = .title
        titleLabel.textAlignment = .center
        titleLabel.text = option.verifyTitle()
        contentStackView.addArrangedSubview(titleLabel)

        let descLabel = UILabel()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.numberOfLines = 0
        descLabel.style = .description
        descLabel.attributedText = option.verifyDescription().attributedForDescription()
        descLabel.textAlignment = .center
        contentStackView.addArrangedSubview(descLabel)
    }

}

extension VerifyEmergencyKitView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        // The continue button gets enabled when tapping on this link
        continueButton.isEnabled = true

        delegate?.didTapOnOpenLink()
    }

}

extension VerifyEmergencyKitView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        delegate?.didTapOnContinue()
    }

}
