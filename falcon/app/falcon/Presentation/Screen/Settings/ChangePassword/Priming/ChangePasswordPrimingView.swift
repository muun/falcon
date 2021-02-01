//
//  ChangePasswordPrimingView.swift
//  falcon
//
//  Created by Manu Herrera on 27/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ChangePasswordPrimingViewDelegate: class {
    func continueButtonTap()
}

final class ChangePasswordPrimingView: UIView {

    private var contentView: UIView!
    private var contentVerticalStack: UIStackView!
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var continueButton: ButtonView!

    private weak var delegate: ChangePasswordPrimingViewDelegate?

    init(delegate: ChangePasswordPrimingViewDelegate?) {
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

        makeViewTestable()
    }

    private func setUpContinueButton() {
        continueButton = ButtonView()
        continueButton.buttonText = L10n.ChangePasswordPrimingView.s1
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

    private func setUpLabels() {
        setUpTitleLabel()
        setUpDescriptionLabel()
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

        setUpImage()
        setUpLabels()
    }

    private func setUpImage() {
        imageView = UIImageView()
        imageView.image = Asset.Assets.changePassword.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentVerticalStack.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 230)
        ])

        contentVerticalStack.setCustomSpacing(40, after: imageView)
    }

    private func setUpTitleLabel() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.text = L10n.ChangePasswordPrimingView.s2
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
        descriptionLabel.attributedText = L10n.ChangePasswordPrimingView.s3
            .attributedForDescription(alignment: .center)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.addArrangedSubview(descriptionLabel)
    }

}

extension ChangePasswordPrimingView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        delegate?.continueButtonTap()
    }

}

extension ChangePasswordPrimingView: UITestablePage {

    typealias UIElementType = UIElements.Pages.ChangePasswordPriming

    func makeViewTestable() {
        self.makeViewTestable(self, using: .root)
        self.makeViewTestable(continueButton, using: .continueButton)
    }

}
