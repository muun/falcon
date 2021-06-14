//
//  LNURLLoadingView.swift
//  falcon
//
//  Created by Federico Bond on 22/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

protocol LNURLLoadingViewDelegate: AnyObject {
    func didTapGoToHome()
}

class LNURLLoadingView: UIView {

    private let spinner = UIActivityIndicatorView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let backButton = ButtonView()

    var isTakingTooLong: Bool = false {
        didSet {
            if isTakingTooLong {
                spinner.color = Asset.Colors.muunRed.color
                backButton.isHidden = false
            } else {
                spinner.color = Asset.Colors.muunGrayDark.color
                backButton.isHidden = true
            }
        }
    }

    weak var delegate: LNURLLoadingViewDelegate?

    var titleText: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var attributedTitleText: NSAttributedString? {
        get {
            titleLabel.attributedText
        }
        set {
            titleLabel.attributedText = newValue
        }
    }
    var descriptionText: String? {
        get {
            descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }
    var attributedDescriptionText: NSAttributedString? {
        get {
            descriptionLabel.attributedText
        }
        set {
            descriptionLabel.attributedText = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        spinner.color = Asset.Colors.muunGrayDark.color
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(spinner)
        stackView.setCustomSpacing(24, after: spinner)

        titleLabel.textAlignment = .center
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .desc)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(16, after: titleLabel)

        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.style = .description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(descriptionLabel)

        backButton.buttonText = L10n.ErrorView.goToHome
        backButton.delegate = self
        backButton.isHidden = true
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: backButton.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }

}

extension LNURLLoadingView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        delegate?.didTapGoToHome()
    }

}
