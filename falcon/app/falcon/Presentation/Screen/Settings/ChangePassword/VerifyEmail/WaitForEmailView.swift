//
//  WaitForEmailView.swift
//  falcon
//
//  Created by Manu Herrera on 29/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol WaitForEmailViewDelegate: class {
    func didTapOpenEmailClient()
}

final class WaitForEmailView: UIView {

    private var titleAndDescriptionView: TitleAndDescriptionView!
    private var openEmailClientButton: LinkButtonView!
    private var emailImageView: UIImageView!
    private var loadingLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    private var emailErrorLabel: UILabel!

    private weak var delegate: WaitForEmailViewDelegate?

    private var bottomMarginConstraint: NSLayoutConstraint!

    init(delegate: WaitForEmailViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpTitleAndDescriptionView()
        setUpEmailImage()
        setUpLoading()
        setUpEmailErrorLabel()
        setUpOpenEmailClientButton()

        makeViewTestable()
    }

    private func setUpTitleAndDescriptionView() {
        titleAndDescriptionView = TitleAndDescriptionView()
        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        titleAndDescriptionView.animate()
        addSubview(titleAndDescriptionView)

        NSLayoutConstraint.activate([
            titleAndDescriptionView.topAnchor.constraint(equalTo: topAnchor),
            titleAndDescriptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            titleAndDescriptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    private func setUpEmailImage() {
        emailImageView = UIImageView()
        emailImageView.image = Asset.Assets.envelope.image
        emailImageView.contentMode = .scaleAspectFit
        emailImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(emailImageView)
        NSLayoutConstraint.activate([
            emailImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -32),
            emailImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailImageView.heightAnchor.constraint(equalToConstant: 145),
            emailImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setUpLoading() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = Asset.Colors.muunBlue.color
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.alpha = 0
        addSubview(activityIndicator)

        loadingLabel = UILabel()
        loadingLabel.style = .description
        loadingLabel.text = L10n.WaitForEmailView.s1
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.alpha = 0
        addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: emailImageView.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8),
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setUpEmailErrorLabel() {
        emailErrorLabel = UILabel()
        emailErrorLabel.numberOfLines = 0
        emailErrorLabel.style = .description

        let bold = L10n.WaitForEmailView.s2
        emailErrorLabel.attributedText = L10n.WaitForEmailView.s4
            .attributedForDescription(alignment: .center)
            .set(bold: bold, color: Asset.Colors.title.color)
        emailErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        emailErrorLabel.alpha = 0
        addSubview(emailErrorLabel)

        NSLayoutConstraint.activate([
            emailErrorLabel.topAnchor.constraint(equalTo: emailImageView.bottomAnchor, constant: 16),
            emailErrorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailErrorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            emailErrorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    private func setUpOpenEmailClientButton() {
        openEmailClientButton = LinkButtonView()
        openEmailClientButton.delegate = self
        openEmailClientButton.buttonText = L10n.WaitForEmailView.s3

        openEmailClientButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(openEmailClientButton)
        NSLayoutConstraint.activate([
            openEmailClientButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            openEmailClientButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            openEmailClientButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    // MARK: - View Controller Actions

    func setButtonEnabled(_ isEnabled: Bool) {
        openEmailClientButton.isEnabled = isEnabled
    }

    func startLoading() {
        hideErrorMessage()
        activityIndicator.startAnimating()
        activityIndicator.animate(direction: .topToBottom, duration: .short)
        loadingLabel.animate(direction: .topToBottom, duration: .short)
    }

    func stopLoading() {
        activityIndicator.stopAnimating()
        loadingLabel.animateOut(direction: .bottomToTop, duration: .short)
        activityIndicator.animateOut(direction: .bottomToTop, duration: .short)
    }

    func displayErrorMessage() {
        stopLoading()
        emailImageView.image = Asset.Assets.emailExpired.image
        emailErrorLabel.isHidden = false
        emailErrorLabel.animate(direction: .topToBottom, duration: .short)
    }

    func hideErrorMessage() {
        emailImageView.image = Asset.Assets.envelope.image
        emailErrorLabel.isHidden = true
    }

    func set(title: String, description: NSAttributedString?) {
        titleAndDescriptionView.titleText = title
        titleAndDescriptionView.descriptionText = description
    }

}

extension WaitForEmailView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        delegate?.didTapOpenEmailClient()
    }

}

extension WaitForEmailView: UITestablePage {

    typealias UIElementType = UIElements.Pages.VerifyEmailPage

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
    }

}
