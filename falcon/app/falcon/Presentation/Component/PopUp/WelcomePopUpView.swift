//
//  WelcomePopUpView.swift
//  falcon
//
//  Created by Manu Herrera on 29/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class WelcomePopUpView: UIView {

    private let card: UIView! = UIView()
    private let astronautImage: UIImageView! = UIImageView()
    private let messageLabel: UILabel! = UILabel()
    private let continueButton: SmallButtonView! = SmallButtonView()
    private weak var delegate: DisplayedPopupDelegate?

    init(delegate: DisplayedPopupDelegate) {
        super.init(frame: .zero)
        setUpView()
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpCard()
        setUpMessageLabel()
        setUpImageView()
        setUpButton()
    }

    fileprivate func setUpCard() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Asset.Colors.cellBackground.color
        card.roundCorners(cornerRadius: 8, clipsToBounds: true)
        addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            card.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    fileprivate func setUpMessageLabel() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.attributedText = L10n.WelcomePopUpView.message
            .attributedForDescription()
        messageLabel.font = Constant.Fonts.description
        messageLabel.textColor = Asset.Colors.title.color
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        card.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            messageLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24)
        ])
    }

    fileprivate func setUpImageView() {
        astronautImage.translatesAutoresizingMaskIntoConstraints = false
        astronautImage.image = Asset.Assets.welcomeAstronaut.image
        astronautImage.contentMode = .scaleAspectFit
        card.addSubview(astronautImage)
        NSLayoutConstraint.activate([
            astronautImage.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            astronautImage.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .sideMargin),
            astronautImage.heightAnchor.constraint(equalToConstant: 256),
            astronautImage.widthAnchor.constraint(equalToConstant: 290),
            astronautImage.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            astronautImage.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            astronautImage.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])
    }

    fileprivate func setUpButton() {
        continueButton.delegate = self
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.isEnabled = true
        continueButton.buttonText = L10n.WelcomePopUpView.button
        card.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            continueButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

extension WelcomePopUpView: SmallButtonViewDelegate {
    func button(didPress button: SmallButtonView) {
        delegate?.dismiss(popup: self)
    }
}
