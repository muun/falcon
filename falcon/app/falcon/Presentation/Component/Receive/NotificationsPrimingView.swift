//
//  NotificationsPrimingView.swift
//  falcon
//
//  Created by Manu Herrera on 01/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol NotificationsPrimingViewDelegate: AnyObject {
    func didTapOnSkipButton()
    func permissionGranted()
    func askForPushNotificationPermission()
}

final class NotificationsPrimingView: UIView {

    private let contentContainerView = UIView()
    private let contentStackView = UIStackView()
    private let buttonsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let enableButton = ButtonView()
    private let skipButton = LinkButtonView()

    private weak var delegate: NotificationsPrimingViewDelegate?

    init(delegate: NotificationsPrimingViewDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        backgroundColor = Asset.Colors.background.color
        setUpContentStackView()
        setUpButtons()

        makeViewTestable()
    }

    private func setUpContentStackView() {
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

            contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: contentContainerView.centerYAnchor)
        ])

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Asset.Assets.notificationsPriming.image
        contentStackView.addArrangedSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.style = .title
        titleLabel.textAlignment = .center
        contentStackView.addArrangedSubview(titleLabel)

        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.numberOfLines = 0
        descLabel.style = .description
        contentStackView.addArrangedSubview(descLabel)
    }

    private func setUpButtons() {
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.spacing = 0
        buttonsStackView.axis = .vertical
        buttonsStackView.alignment = .center
        addSubview(buttonsStackView)

        enableButton.translatesAutoresizingMaskIntoConstraints = false
        enableButton.isEnabled = true
        enableButton.delegate = self
        enableButton.buttonText = L10n.NotificationsPrimingView.s3
        buttonsStackView.addArrangedSubview(enableButton)

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.isEnabled = true
        skipButton.delegate = self
        skipButton.buttonText = L10n.NotificationsPrimingView.s4
        buttonsStackView.addArrangedSubview(skipButton)

        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            buttonsStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            enableButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor),
            skipButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor)
        ])
    }

    // MARK: - View Controller actions -

    func setUpForOnChain() {
        skipButton.isHidden = false
        titleLabel.text = L10n.NotificationsPrimingView.s1
        descLabel.attributedText = L10n.NotificationsPrimingView.s2
            .attributedForDescription(alignment: .center)
    }

    func setUpForLightning() {
        skipButton.isHidden = true
        titleLabel.text = L10n.NotificationsPrimingView.s5
        descLabel.attributedText = L10n.NotificationsPrimingView.s6
            .attributedForDescription(alignment: .center)
    }

}

extension NotificationsPrimingView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            switch status {
            case .notDetermined:
                self.delegate?.askForPushNotificationPermission()
            case .authorized, .ephemeral, .provisional:
                self.delegate?.permissionGranted()
            case .denied:
                // Open settings
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            default:
                return
            }
        }
    }

}

extension NotificationsPrimingView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        delegate?.didTapOnSkipButton()
    }
}

extension NotificationsPrimingView: UITestablePage {
    typealias UIElementType = UIElements.Pages.ReceivePage

    func makeViewTestable() {
        makeViewTestable(enableButton, using: .enablePush)
    }
}
