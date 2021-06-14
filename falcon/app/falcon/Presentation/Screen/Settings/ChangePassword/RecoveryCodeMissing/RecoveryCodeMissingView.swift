//
//  RecoveryCodeMissingView.swift
//  falcon
//
//  Created by Manu Herrera on 31/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol RecoveryCodeMissingViewDelegate: AnyObject {
    func continueButtonTap()
}

final class RecoveryCodeMissingView: UIView {

    private var contentView: UIView!
    private var contentVerticalStack: UIStackView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var continueButton: ButtonView!

    private weak var delegate: RecoveryCodeMissingViewDelegate?

    init(delegate: RecoveryCodeMissingViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpContinueButton()
        setUpContentView()
    }

    private func setUpContinueButton() {
        continueButton = ButtonView()
        continueButton.buttonText = L10n.RecoveryCodeMissingView.s1
        continueButton.isEnabled = true
        continueButton.delegate = self

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    private func setUpContentView() {
        contentView = UIView()
        contentView.backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: continueButton.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        setUpStackView()
    }

    private func setUpStackView() {
        contentVerticalStack = UIStackView()
        contentVerticalStack.axis = .vertical
        contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.spacing = 8
        contentVerticalStack.alignment = .center

        addSubview(contentVerticalStack)
        NSLayoutConstraint.activate([
            contentVerticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentVerticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentVerticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .sideMargin),
            contentVerticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.sideMargin)
        ])

        setUpLabels()
    }

    private func setUpLabels() {
        setUpTitleLabel()
        setUpDescriptionLabel()
    }

    private func setUpTitleLabel() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.text = L10n.RecoveryCodeMissingView.s2
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.textAlignment = .center

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.addArrangedSubview(titleLabel)
    }

    private func setUpDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.style = .description
        descriptionLabel.attributedText = L10n.RecoveryCodeMissingView.s3
            .attributedForDescription(alignment: .center)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.addArrangedSubview(descriptionLabel)
    }

}

extension RecoveryCodeMissingView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        delegate?.continueButtonTap()
    }

}
