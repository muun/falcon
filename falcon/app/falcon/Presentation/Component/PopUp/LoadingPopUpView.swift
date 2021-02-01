//
//  LoadingPopUpView.swift
//  falcon
//
//  Created by Manu Herrera on 10/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class LoadingPopUpView: UIView {

    private let card: UIView! = UIView()
    private let activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView()
    private let messageLabel: UILabel! = UILabel()

    private let loadingText: String

    init(loadingText: String) {
        self.loadingText = loadingText

        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Asset.Colors.cellBackground.color
        card.roundCorners(cornerRadius: 14, clipsToBounds: true)
        addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .whiteLarge
        activityIndicator.color = Asset.Colors.muunGrayDark.color
        card.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: card.topAnchor, constant: 32)
        ])
        activityIndicator.startAnimating()

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.attributedText = loadingText.attributedForDescription()
        messageLabel.style = .description
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        card.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            messageLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: .sideMargin),
            messageLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

}
