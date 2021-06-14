//
//  SaveEmergencyKitOptionView.swift
//  falcon
//
//  Created by Manu Herrera on 10/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol SaveEmergencyKitOptionViewDelegate: AnyObject {
    func didTapOnOption(_ option: EKOption)
}

final class SaveEmergencyKitOptionView: UIView {

    private var titleLabel: UILabel! = UILabel()
    private var descriptionLabel: UILabel! = UILabel()
    private var logo: UIImageView! = UIImageView()
    private var chevron: UIImageView! = UIImageView()
    private var tagView: UIView! = UIView()
    private var tagLabel: UILabel! = UILabel()
    private var separator: UIView! = UIView()
    private var labelsView: UIView! = UIView()

    private weak var delegate: SaveEmergencyKitOptionViewDelegate?
    private let option: EKOption

    init(delegate: SaveEmergencyKitOptionViewDelegate?,
         option: EKOption) {
        self.delegate = delegate
        self.option = option
        super.init(frame: .zero)

        setUpView()
        populateView(option: option)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpLogoImage()
        setUpLabelsView()
        setUpChevron()
        setUpSeparator()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: .optionTap))
    }

    private func setUpLogoImage() {
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        addSubview(logo)

        NSLayoutConstraint.activate([
            logo.heightAnchor.constraint(equalToConstant: 40),
            logo.widthAnchor.constraint(equalToConstant: 40),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor),
            logo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin)
        ])
    }

    private func setUpLabelsView() {
        labelsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelsView)

        NSLayoutConstraint.activate([
            labelsView.topAnchor.constraint(equalTo: topAnchor, constant: .sideMargin),
            labelsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            labelsView.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 20)
        ])

        setUpLabels()
        setUpTagView()
    }

    private func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .homeCurrency, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsView.addSubview(titleLabel)

        descriptionLabel.style = .description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: labelsView.topAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(equalTo: labelsView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor)
        ])
    }

    private func setUpTagView() {
        tagView.translatesAutoresizingMaskIntoConstraints = false
        tagView.roundCorners(cornerRadius: 10, clipsToBounds: true)
        tagView.backgroundColor = Asset.Colors.muunBluePale.color
        labelsView.addSubview(tagView)

        tagLabel.numberOfLines = 1
        tagLabel.textColor = Asset.Colors.muunBlue.color
        tagLabel.font = Constant.Fonts.system(size: .notice, weight: .semibold)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagView.addSubview(tagLabel)

        NSLayoutConstraint.activate([
            tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            tagLabel.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
            tagLabel.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 8),
            tagLabel.trailingAnchor.constraint(equalTo: tagView.trailingAnchor, constant: -8),

            tagView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            tagView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            tagView.heightAnchor.constraint(equalToConstant: 20)
        ])

        tagView.isHidden = true
    }

    private func setUpChevron() {
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = Asset.Assets.chevron.image
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = Asset.Colors.muunGrayLight.color
        addSubview(chevron)

        NSLayoutConstraint.activate([
            chevron.heightAnchor.constraint(equalToConstant: 32),
            chevron.widthAnchor.constraint(equalToConstant: 32),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            chevron.leadingAnchor.constraint(equalTo: labelsView.trailingAnchor, constant: .sideMargin)
        ])
    }

    private func setUpSeparator() {
        separator.backgroundColor = Asset.Colors.separator.color
        separator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func populateView(option: EKOption) {
        logo.image = option.option.image()
        titleLabel.text = option.option.title()
        descriptionLabel.attributedText = option.option.description()

        if option.isRecommended {
            tagLabel.text = L10n.SaveEmergencyKitOptionView.recommended
            tagView.isHidden = false
        }

        if !option.isEnabled {
            self.alpha = 0.3
            tagLabel.text = L10n.SaveEmergencyKitOptionView.notEnabled
            tagView.isHidden = false
            descriptionLabel.attributedText = option.option.disabledDescription()
        }
    }

    @objc func didTapOnOption() {
        delegate?.didTapOnOption(option)
    }
}

fileprivate extension Selector {
    static let optionTap = #selector(SaveEmergencyKitOptionView.didTapOnOption)
}
